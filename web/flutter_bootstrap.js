{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: "{{flutter_service_worker_version}}"
  },
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({
      // Force HTML renderer to avoid CanvasKit WebGL context-loss errors
      // (_handledContextLostEvent LateInitializationError on tab switch / GPU reset)
      renderer: "html",
    });
    await appRunner.runApp();
  }
});
