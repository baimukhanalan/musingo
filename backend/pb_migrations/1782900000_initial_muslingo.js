migrate((app) => {
  const users = app.findCollectionByNameOrId("users")
  users.listRule = "@request.auth.id != ''"
  users.viewRule = "@request.auth.id != ''"
  users.createRule = ""
  users.updateRule = "id = @request.auth.id"
  users.deleteRule = "id = @request.auth.id"
  users.authRule = ""
  const nameField = users.fields.getByName("name")
  nameField.required = true
  nameField.min = 2
  nameField.max = 60
  nameField.presentable = true
  users.addIndex("idx_users_name", false, "name", "")
  app.save(users)

  const progress = new Collection({
    type: "base",
    name: "progress",
    listRule: "@request.auth.id != ''",
    viewRule: "@request.auth.id != ''",
    createRule: null,
    updateRule: null,
    deleteRule: null,
    fields: [
      {
        name: "user",
        type: "relation",
        required: true,
        maxSelect: 1,
        collectionId: users.id,
        cascadeDelete: true,
      },
      {
        name: "displayName",
        type: "text",
        required: true,
        min: 2,
        max: 60,
      },
      { name: "xp", type: "number", min: 0 },
      { name: "level", type: "number", min: 1 },
      { name: "streak", type: "number", min: 0 },
      { name: "hearts", type: "number", min: 0, max: 5 },
      { name: "isPremium", type: "bool" },
      { name: "totalLessons", type: "number", min: 0 },
      { name: "totalMinutes", type: "number", min: 0 },
      { name: "learnedAyats", type: "number", min: 0 },
      { name: "learnedDuas", type: "number", min: 0 },
      { name: "lastStudyDay", type: "text", max: 10 },
      { name: "completedLessons", type: "json", maxSize: 200000 },
    ],
    indexes: [
      "CREATE UNIQUE INDEX idx_progress_user ON progress (user)",
      "CREATE INDEX idx_progress_xp ON progress (xp DESC)",
    ],
  })
  app.save(progress)
}, (app) => {
  try {
    app.delete(app.findCollectionByNameOrId("progress"))
  } catch (_) {}
  const users = app.findCollectionByNameOrId("users")
  users.listRule = "id = @request.auth.id"
  users.viewRule = "id = @request.auth.id"
  users.removeIndex("idx_users_name")
  app.save(users)
})
