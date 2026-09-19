/// Central place to construct and wire together repositories and services.
///
/// Backend/database teammates register their repository implementations
/// here; frontend teammates consume the getters below inside their
/// feature Providers instead of constructing repositories themselves.
class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  // Example (to be filled in as repositories are implemented):
  // late final StepRepository stepRepository = StepRepositoryImpl();
}
