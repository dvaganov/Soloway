namespace SoloWay {
  public class SidePanel : Gtk.Revealer {
    private static SidePanel self;

    private SidePanel() {
      transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
      valign = Gtk.Align.CENTER;

      var grid = new Gtk.Grid();
      grid.margin = 5;
      grid.row_spacing = 10;
      add(grid);

      var label = new Gtk.Label("Title:");
      grid.attach(label, 0, 0);

      label = new Gtk.Label("URL:");
      grid.attach(label, 0, 2);

      var entry = new Gtk.Entry();
      grid.attach(entry, 0, 1);

      var btn = new Gtk.Button.with_mnemonic("_Add");
      btn.get_style_context().add_class("suggested-action");
      btn.sensitive = false;
      btn.clicked.connect(add_entry);
      grid.attach (btn, 0, 4);

      entry = new Gtk.Entry ();
      entry.changed.connect ((editable) => {
        var tmp_entry = editable as Gtk.Entry;
        if (tmp_entry.text.has_prefix("http://") || tmp_entry.text.has_prefix("https://")) {
          btn.sensitive = true;
        } else {
          btn.sensitive = false;
        }
      });
      grid.attach(entry, 0, 3);
    }
    private void add_entry(Gtk.Button btn) {
      var grid = this.get_child() as Gtk.Grid;
      var entry = grid.get_child_at(0, 1) as Gtk.Entry;
      var title = entry.text;
      entry = grid.get_child_at(0, 3) as Gtk.Entry;
      var uri = entry.text;
      Playlist.get_instance().add_entry(title, uri);
      this.show_panel();
    }
    public void show_panel() {
      if (reveal_child == false) {
        var grid = this.get_child() as Gtk.Grid;
        var entry = grid.get_child_at(0, 1) as Gtk.Entry;
        entry.text = "";
        entry = grid.get_child_at(0, 3) as Gtk.Entry;
        entry.text = "";
        reveal_child = true;
      } else if (reveal_child == true) {
        reveal_child = false;
      }
    }
    public Gtk.Button get_controller() {
      var btn = new Gtk.ToggleButton.with_mnemonic("_Add");
      btn.toggled.connect(() => {
        this.show_panel();
      });
      return btn;
    }
    public static SidePanel get_instance() {
      if (self == null) {
        self = new SidePanel();
      }
      return self;
    }
  }
}
