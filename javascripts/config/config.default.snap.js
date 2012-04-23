
define(["plugins/snap/snap", "plugins/autoscroll/autoscroll"], function(Snap, Autoscroll) {
  return {
    build: function() {
      return {
        plugins: [new Snap(), new Autoscroll()]
      };
    }
  };
});
