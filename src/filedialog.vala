namespace SoloWay {
  public class OpenFileDialog : GLib.Object {
    private static Gtk.FileChooserDialog createDialog(Gtk.Window? window) {
      var _dialog = new Gtk.FileChooserDialog(null, window, Gtk.FileChooserAction.OPEN, null);
      _dialog.add_button ("_Cancel", Gtk.ResponseType.CANCEL);
      _dialog.add_button ("_Open", Gtk.ResponseType.ACCEPT).get_style_context().add_class("suggested-action");
      var filter = new Gtk.FileFilter();
      filter.set_filter_name("SoloWay playlist");
      filter.add_pattern("*.swp");
      _dialog.add_filter(filter);
      return _dialog;
    }
    public static void run(Gtk.Window? window) {
      var _dialog = createDialog(window);
      if (_dialog.run() == Gtk.ResponseType.ACCEPT) {
        var filepath = _dialog.get_filename();
        Playlist.getInstance().open(filepath);
      }
      _dialog.destroy();
    }
  }

  public class SaveFileDialog : GLib.Object {
    private static Gtk.FileChooserDialog createDialog(Gtk.Window? window) {
      var _dialog = new Gtk.FileChooserDialog(null, window, Gtk.FileChooserAction.SAVE, null);
      _dialog.add_button ("_Cancel", Gtk.ResponseType.CANCEL);
      _dialog.add_button ("_Save", Gtk.ResponseType.ACCEPT).get_style_context().add_class("suggested-action");
      var filter = new Gtk.FileFilter();
      filter.set_filter_name("SoloWay playlist");
      filter.add_pattern("*.swp");
      _dialog.add_filter(filter);
      return _dialog;
    }
    public static void run(Gtk.Window? window) {
      var _dialog = createDialog(window);
      if (_dialog.run() == Gtk.ResponseType.ACCEPT) {
        var filepath = _dialog.get_filename();
        if (!filepath.has_suffix (".swp")) {
          filepath += ".swp";
        }
        Playlist.getInstance().save(filepath);
      }
      _dialog.close ();
    }
  }
}
