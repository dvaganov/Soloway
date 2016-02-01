namespace SoloWay {
  public class Playlist : GLib.Object {
    private static Playlist self;
    private struct SongEnry {
      string title;
      string uri;
    }
    private GLib.KeyFile file;
    //private GLib.GenericArray<SongEnry?> playlist;
    private GLib.ListStore playlist;
    private string group_name = "Playlist";

    public signal void changed(Playlist pl);
    public uint length {
      get {return playlist.get_n_items();}
      private set {}
    }

    private Playlist() {
      this.file = new GLib.KeyFile();
      this.file.set_list_separator('=');
      //this.playlist = new GLib.GenericArray<SongEnry?>();
      this.playlist = new GLib.ListStore(typeof(Entry));
    }
    public void open(string filepath) {
      try {
        this.file.load_from_file(filepath, GLib.KeyFileFlags.NONE);
        var titles = file.get_keys(group_name);
        string title, uri;
        for (var i = 0; i < titles.length; i++) {
          title = titles[i];
          uri = this.file.get_string(this.group_name, title);
          //this.playlist.add({title, uri});
          this.playlist.append(new Entry(title, uri));
        }
        this.changed(this);
      } catch(GLib.KeyFileError key_err) {
        print(@"Load file: $(key_err.message)\n");
      } catch(GLib.FileError err) {
        print(@"Load file: $(err.message)\n");
      }
    }
    public void save(string filepath) {
      /*SongEnry entry;
      for (var i = 0; i < playlist.length; i++) {
        entry = this.playlist.get(i);
        this.file.set_string(this.group_name, entry.title, entry.uri);
      }*/
      Entry entry;
      uint i = 0;
      while (true) {
        entry = playlist.get_object(i++) as Entry;
        if (entry != null) {
          this.file.set_string(this.group_name, entry.title, entry.uri);
        } else {
          break;
        }
      }
      try {
        this.file.save_to_file(filepath);
      } catch (GLib.FileError e) {
        print(@"Playlist.save(): $(e.message)");
      }
    }
    public void add_entry(string title, string uri) {
      //this.playlist.add({title, uri});
      this.playlist.append(new Entry(title, uri));
      this.changed(this);
    }
    public void get_entry(int index, out string title, out string uri) {
      //var entry = this.playlist.get(index);
      var entry = this.playlist.get_object(index) as Entry;
      title = entry.title;
      uri = entry.uri;
    }
    public void remove_entry(int index) {
      //this.playlist.remove_index(index);
      this.changed(this);
    }
    public static Playlist get_instance() {
      if (self == null) {
        self = new Playlist();
      }
      return self;
    }
    public static GLib.ListStore get_model() {
      return self.playlist;
    }
  }
}
