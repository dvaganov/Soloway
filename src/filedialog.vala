namespace SoloWay {
  namespace Dialogs {
    private const string PLAYLIST_FORMAT = "swp";
    private Gtk.FileFilter create_filter() {
      var filter = new Gtk.FileFilter();
      filter.set_filter_name("SoloWay playlist");
      filter.add_pattern(@"*.$PLAYLIST_FORMAT");
      return filter;
    }
    public void open_file(Gtk.Window? window) {
      var _dialog = new Gtk.FileChooserDialog(null, window, Gtk.FileChooserAction.OPEN, null);
      _dialog.add_button ("_Cancel", Gtk.ResponseType.CANCEL);
      _dialog.add_button ("_Open", Gtk.ResponseType.ACCEPT).get_style_context().add_class("suggested-action");
      _dialog.add_filter(create_filter());
      if (_dialog.run() == Gtk.ResponseType.ACCEPT) {
        var filepath = _dialog.get_filename();
        Playlist.get().open(filepath);
      }
      _dialog.destroy();
    }
    public void save_file(Gtk.Window? window) {
      var _dialog = new Gtk.FileChooserDialog(null, window, Gtk.FileChooserAction.SAVE, null);
      _dialog.add_button ("_Cancel", Gtk.ResponseType.CANCEL);
      _dialog.add_button ("_Save", Gtk.ResponseType.ACCEPT).get_style_context().add_class("suggested-action");
      _dialog.add_filter(create_filter());
      if (_dialog.run() == Gtk.ResponseType.ACCEPT) {
        var filepath = _dialog.get_filename();
        if (!filepath.has_suffix (@".$PLAYLIST_FORMAT")) {
          filepath += @".$PLAYLIST_FORMAT";
        }
        Playlist.get().save(filepath);
      }
      _dialog.close ();
    }
  }
}
