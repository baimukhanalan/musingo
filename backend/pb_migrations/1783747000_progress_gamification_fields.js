migrate((app) => {
  const progress = app.findCollectionByNameOrId("progress")
  progress.fields.add({ name: "energy", type: "number", min: 0 })
  progress.fields.add({ name: "dailyGoal", type: "number", min: 1 })
  progress.fields.add({ name: "dailyProgress", type: "number", min: 0 })
  progress.fields.add({ name: "lessonAttempts", type: "number", min: 0 })
  progress.fields.add({ name: "speechAttempts", type: "number", min: 0 })
  progress.fields.add({ name: "rewardChestsOpened", type: "number", min: 0 })
  progress.fields.add({ name: "rewardHistory", type: "json", maxSize: 200000 })
  progress.fields.add({
    name: "downloadedAudioChapters",
    type: "json",
    maxSize: 200000,
  })
  app.save(progress)
}, (app) => {
  const progress = app.findCollectionByNameOrId("progress")
  for (const field of [
    "dailyGoal",
    "energy",
    "dailyProgress",
    "lessonAttempts",
    "speechAttempts",
    "rewardChestsOpened",
    "rewardHistory",
    "downloadedAudioChapters",
  ]) {
    try {
      progress.fields.removeByName(field)
    } catch (_) {}
  }
  app.save(progress)
})
