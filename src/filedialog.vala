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
      var dialog = new Gtk.FileChooserDialog(null, window, Gtk.FileChooserAction.OPEN, null);
      dialog.add_button ("_Cancel", Gtk.ResponseType.CANCEL);
      dialog.add_button ("_Open", Gtk.ResponseType.ACCEPT).get_style_context().add_class("suggested-action");
      dialog.add_filter(create_filter());
      if (dialog.run() == Gtk.ResponseType.ACCEPT) {
        var filename = dialog.get_filename();
        PlayGList.get_instance().open(filename);
      }
      dialog.destroy();
    }
    public void save_file(Gtk.Window? window) {
      var dialog = new Gtk.FileChooserDialog(null, window, Gtk.FileChooserAction.SAVE, null);
      dialog.add_button ("_Cancel", Gtk.ResponseType.CANCEL);
      dialog.add_button ("_Save", Gtk.ResponseType.ACCEPT).get_style_context().add_class("suggested-action");
      dialog.add_filter(create_filter());
      if (dialog.run() == Gtk.ResponseType.ACCEPT) {
        var filename = dialog.get_filename();
        if (!filename.has_suffix (@".$PLAYLIST_FORMAT")) {
          filename += @".$PLAYLIST_FORMAT";
        }
        PlayGList.get_instance().save(filename);
      }
      dialog.close ();
    }
  }
}
