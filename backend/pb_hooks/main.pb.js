onRecordAfterCreateSuccess((e) => {
  const collection = e.app.findCollectionByNameOrId("progress")
  const progress = new Record(collection)
  progress.set("user", e.record.id)
  progress.set("displayName", e.record.getString("name"))
  progress.set("xp", 0)
  progress.set("level", 1)
  progress.set("streak", 0)
  progress.set("hearts", 5)
  progress.set("energy", 0)
  progress.set("isPremium", false)
  progress.set("totalLessons", 0)
  progress.set("totalMinutes", 0)
  progress.set("learnedAyats", 0)
  progress.set("learnedDuas", 0)
  progress.set("dailyGoal", 3)
  progress.set("dailyProgress", 0)
  progress.set("lessonAttempts", 0)
  progress.set("speechAttempts", 0)
  progress.set("rewardChestsOpened", 0)
  progress.set("rewardHistory", [])
  progress.set("lastStudyDay", "")
  progress.set("completedLessons", [])
  e.app.save(progress)
  e.next()
}, "users")

onRecordAfterUpdateSuccess((e) => {
  const progressLib = require(`${__hooks}/progress.js`)
  try {
    const progress = progressLib.find(e.app, e.record.id)
    progress.set("displayName", e.record.getString("name"))
    e.app.save(progress)
  } catch (_) {}
  e.next()
}, "users")

routerAdd("GET", "/api/muslingo/me", (e) => {
  const progressLib = require(`${__hooks}/progress.js`)
  return e.json(200, progressLib.serialize(progressLib.find(e.app, e.auth.id)))
}, $apis.requireAuth("users"))

routerAdd("GET", "/api/muslingo/leaderboard", (e) => {
  const progressLib = require(`${__hooks}/progress.js`)
  const records = e.app.findRecordsByFilter("progress", "", "-xp", 50, 0)
  return e.json(200, records.map(progressLib.serialize))
}, $apis.requireAuth("users"))

routerAdd("GET", "/api/muslingo/quran/audio/{ayah}", (e) => {
  const ayah = Number(e.request.pathValue("ayah"))
  if (!Number.isInteger(ayah) || ayah < 1 || ayah > 6236) {
    throw new BadRequestError("Invalid Quran audio reference")
  }

  const response = $http.send({
    method: "GET",
    url: `https://cdn.islamic.network/quran/audio/128/ar.alafasy/${ayah}.mp3`,
    timeout: 20,
  })
  if (response.statusCode !== 200 && response.statusCode !== 206) {
    throw new InternalServerError("Quran audio source is unavailable")
  }
  return e.blob(200, "audio/mpeg", response.body)
})

routerAdd("POST", "/api/speech/evaluate", (e) => {
  const progressLib = require(`${__hooks}/progress.js`)
  const body = e.requestInfo().body || {}
  const target = String(body.target || "")
  const phoneticTarget = String(body.phoneticTarget || "")
  const transcript = String(body.transcript || "")
  const passScore = Math.max(0, Math.min(100, Number(body.passScore || 60)))
  if (!target) {
    throw new BadRequestError("Speech target is required")
  }
  const targetResult = progressLib.evaluateSpeech(transcript, target, passScore)
  if (!phoneticTarget) return e.json(200, targetResult)
  const phoneticResult = progressLib.evaluateSpeech(
    transcript,
    phoneticTarget,
    passScore,
  )
  return e.json(
    200,
    phoneticResult.score > targetResult.score ? phoneticResult : targetResult,
  )
})

routerAdd("POST", "/api/muslingo/progress/complete", (e) => {
  const progressLib = require(`${__hooks}/progress.js`)
  const body = e.requestInfo().body || {}
  const lessonId = String(body.lessonId || "")
  const lesson = progressLib.lessons[lessonId]
  if (!lesson) {
    throw new BadRequestError("Unknown lesson")
  }

  const progress = progressLib.find(e.app, e.auth.id)
  const completed = progressLib.jsonArray(progress, "completedLessons")

  const firstCompletion = completed.indexOf(lessonId) === -1
  if (firstCompletion) completed.push(lessonId)
  const xpEarned = firstCompletion ? 25 : 5
  const todayDate = new Date()
  const today = todayDate.toISOString().slice(0, 10)
  const yesterdayDate = new Date(todayDate.getTime() - 86400000)
  const yesterday = yesterdayDate.toISOString().slice(0, 10)
  const lastStudyDay = progress.getString("lastStudyDay")
  let streak = progress.getInt("streak")
  const isNewStudyDay = lastStudyDay !== today
  if (isNewStudyDay) {
    streak = lastStudyDay === yesterday ? streak + 1 : 1
  }
  let streakBonus = 0
  if (isNewStudyDay && streak === 7) streakBonus = 10
  if (isNewStudyDay && streak === 30) streakBonus = 50
  if (isNewStudyDay && streak === 100) streakBonus = 200
  const newXp = progress.getInt("xp") + xpEarned + streakBonus

  const errors = Math.max(0, Math.min(5, Number(body.errors || 0)))
  const speechAttempts = Math.max(0, Math.min(50, Number(body.speechAttempts || 0)))
  const rewardToken = String(body.rewardToken || `${lessonId}:${Date.now()}`)
  const energyEarned = Math.max(4, Math.min(12, 12 - (errors * 2)))
  const hearts = progress.getBool("isPremium")
    ? 5
    : Math.max(0, progress.getInt("hearts") - errors)
  const rewardHistory = progressLib.jsonArray(progress, "rewardHistory")
  rewardHistory.push(rewardToken)

  progress.set("xp", newXp)
  progress.set("level", Math.floor(newXp / 500) + 1)
  progress.set("streak", streak)
  progress.set("hearts", hearts)
  progress.set("energy", Math.min(999, progress.getInt("energy") + energyEarned))
  progress.set("totalLessons", progress.getInt("totalLessons") + 1)
  progress.set("totalMinutes", progress.getInt("totalMinutes") + 5)
  progress.set("learnedAyats", progress.getInt("learnedAyats") + (firstCompletion ? lesson.ayats : 0))
  progress.set("learnedDuas", progress.getInt("learnedDuas") + (firstCompletion ? lesson.duas : 0))
  progress.set("dailyProgress", Math.min(progress.getInt("dailyGoal"), progress.getInt("dailyProgress") + 1))
  progress.set("lessonAttempts", progress.getInt("lessonAttempts") + 1)
  progress.set("speechAttempts", progress.getInt("speechAttempts") + speechAttempts)
  progress.set("rewardChestsOpened", progress.getInt("rewardChestsOpened") + 3)
  progress.set("rewardHistory", rewardHistory)
  progress.set("lastStudyDay", today)
  progress.set("completedLessons", completed)
  e.app.save(progress)

  return e.json(200, {
    xpEarned: xpEarned,
    streakBonus: streakBonus,
    firstCompletion: firstCompletion,
    progress: progressLib.serialize(progress),
  })
}, $apis.requireAuth("users"))

routerAdd("POST", "/api/muslingo/progress/restore-heart", (e) => {
  const progressLib = require(`${__hooks}/progress.js`)
  const progress = progressLib.find(e.app, e.auth.id)
  if (progress.getBool("isPremium") || progress.getInt("hearts") >= 5) {
    throw new BadRequestError("Hearts are already full")
  }
  if (progress.getInt("energy") < 20) {
    throw new BadRequestError("Not enough energy")
  }
  progress.set("hearts", Math.min(5, progress.getInt("hearts") + 1))
  progress.set("energy", Math.max(0, progress.getInt("energy") - 20))
  e.app.save(progress)
  return e.json(200, progressLib.serialize(progress))
}, $apis.requireAuth("users"))

routerAdd("DELETE", "/api/muslingo/account", (e) => {
  const progressLib = require(`${__hooks}/progress.js`)
  const progress = progressLib.find(e.app, e.auth.id)
  e.app.delete(progress)
  e.app.delete(e.auth)
  return e.noContent(204)
}, $apis.requireAuth("users"))
