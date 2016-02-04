namespace SoloWay {
  public class PlayGList : GLib.Object, Playlist {
    private static PlayGList self;
    private GLib.KeyFile file;
    private GLib.ListStore playlist;
    private string group_name = "Playlist";

    private PlayGList(GLib.Type? type) {
      type = type != null ? type : typeof(PlaylistRecord);
      this.file = new GLib.KeyFile();
      this.file.set_list_separator('=');
      this.playlist = new GLib.ListStore(type);
    }
    public bool open(string filename) {
      var result = false;
      try {
        this.file.load_from_file(filename, GLib.KeyFileFlags.NONE);
        var titles = file.get_keys(group_name);
        string title, uri;
        for (var i = 0; i < titles.length; i++) {
          title = titles[i];
          uri = this.file.get_string(this.group_name, title);
          this.playlist.append(new Entry(title, uri));
        }
        result = true;
      } catch(GLib.KeyFileError key_err) {
        print(@"Load file: $(key_err.message)\n");
      } catch(GLib.FileError err) {
        print(@"Load file: $(err.message)\n");
      }
      return result;
    }
    public void save(string filename) {
      PlaylistRecord entry;
      uint i = 0;
      while (true) {
        entry = playlist.get_object(i++) as PlaylistRecord;
        if (entry != null) {
          this.file.set_string(this.group_name, entry.title, entry.uri);
        } else {
          break;
        }
      }
      try {
        this.file.save_to_file(filename);
      } catch (GLib.FileError e) {
        print(@"Playlist.save(): $(e.message)");
      }
    }
    public void add(PlaylistRecord entry) {
      this.playlist.append(entry);
    }
    /*public void get_entry(int index, out string title, out string uri) {
      var entry = this.playlist.get_object(index) as Entry;
      title = entry.title;
      uri = entry.uri;
    }*/
    public bool remove(uint position) {
      var result = false;
      if (this.playlist.get_n_items() > position) {
        this.playlist.remove(position);
        result = true;
      }
      return result;
    }
    public static Playlist get_instance(GLib.Type? type = null) {
      if (self == null) {
        self = new PlayGList(type);
      }
      return self;
    }
    public static GLib.ListStore get_model() {
      return self.playlist;
    }
  }
}
