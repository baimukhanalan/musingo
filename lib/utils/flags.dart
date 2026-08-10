/// Компайл-тайм флаги сборки.
///
/// Черновой контент (например таджвид), который ещё НЕ прошёл проверку
/// исламским специалистом, включается только этим флагом и по умолчанию
/// выключен — в прод-сборке его нет. Для ревью собирают превью с
/// `--dart-define=MUSLINGO_DRAFT_CONTENT=true`.
const bool kDraftContentEnabled =
    bool.fromEnvironment('MUSLINGO_DRAFT_CONTENT', defaultValue: false);
