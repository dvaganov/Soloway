namespace SoloWay {
  public class Settings {
    private struct Parameter {
      string key;
      string val;
    }
    private static Settings self;
    private GLib.KeyFile file;
    private string file_name = "soloway.conf";
    private string group_name = "Settings";
    private Parameter[] param_list;

    private Settings() {
      file = new GLib.KeyFile();
      file.set_list_separator('=');
      try {
        file.load_from_file(file_name, GLib.KeyFileFlags.NONE);
        var keys = file.get_keys(group_name);
        param_list = new Parameter[keys.length];
        for (var i = 0; i < keys.length; i++) {
          param_list[i].key = keys[i];
          param_list[i].val = file.get_value(group_name, keys[i]);
        }
      } catch (GLib.KeyFileError e) {
        print(@"Settings(): $(e.message)\n");
      } catch (GLib.FileError e) {
        print(@"Settings(): $(e.message)\n");
      }
    }
    public static void init() {
      if (self == null) {
        self = new Settings();
      }
    }
    public static void set_param(string key, string val) {
      self.file.set_value(self.group_name, key, val);
    }
    public static string get_param(string key) {
      string result = "";
      for (var i = 0; i < self.param_list.length; i++) {
        if (key == self.param_list[i].key) {
          result = self.param_list[i].val;
          break;
        }
      }
      return result;
    }
    public static void save() {
      try {
        self.file.save_to_file(self.file_name);
      } catch (GLib.FileError e) {
        print(@"Settings.save(): $(e.message)");
      }
    }
  }
}
