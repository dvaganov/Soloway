namespace Soloway {
public class App : Gtk.Application {
    private Gtk.Builder builder;
    private Player player;
    private Gtk.HeaderBar headerBar;
    private GLib.DBusProxy proxy;
    private string playlist_path  = "saved.swp";
    public App(string[] args) {
        Object(application_id: "home.dvaganov.soloway");
        this.player = new Player(args);
        player.on_tag_change.connect(song_title_changed_cb);
    }
    protected override void activate() {
        this.builder = new Gtk.Builder.from_file("./ui/soloway.ui");
        this.builder.add_from_file("./ui/menu.ui");
        builder.connect_signals(this);

        var window = this.builder.get_object("app_window") as Gtk.ApplicationWindow;

        var btnMenu = new Gtk.MenuButton();
        btnMenu.image = new Gtk.Image.from_icon_name("open-menu-symbolic", Gtk.IconSize.BUTTON);
        btnMenu.menu_model = this.builder.get_object("menu") as GLib.Menu;
        btnMenu.use_popover = true;

        var listBox = this.builder.get_object("playlist") as Gtk.ListBox;
        listBox.button_press_event.connect((widget, event) => {
            var row = ((Gtk.ListBox) widget).get_row_at_y((int) event.y);
            if (event.button == 3) {
                show_entry_popover(row, null);
            }
            return false;
        });
        listBox.row_activated.connect(this.play_active_row);
        listBox.selected_rows_changed.connect(this.show_edit_button);

        headerBar = new Gtk.HeaderBar();
        headerBar.title = "SoloWay";
        headerBar.has_subtitle = true;
        headerBar.show_close_button = true;
        headerBar.pack_start(this.builder.get_object("hb-box-location") as Gtk.Box);
        headerBar.pack_end(btnMenu);
        headerBar.pack_end(this.builder.get_object("hb-box-btns") as Gtk.Box);

        window.set_titlebar(headerBar);
        window.show_all();
        this.add_window(window);
        this.add_actions();

        window.activate_action("sync_with_file", null);

        this.proxy = new DBusProxy.sync(GLib.Bus.get_sync(GLib.BusType.SESSION, null),
                                        GLib.DBusProxyFlags.NONE,
                                        null,
                                        "org.gnome.SettingsDaemon",
                                        "/org/gnome/SettingsDaemon/MediaKeys",
                                        "org.gnome.SettingsDaemon.MediaKeys",
                                        null);

        this._grab_media_player_keys();

        this.proxy.g_signal.connect((proxy, sender, sig_name, parameters) => {
            if (sig_name != "MediaPlayerKeyPressed") {
                print ("Received an unexpected signal %s from media player".printf(sig_name));
                return;
            }
            var response = parameters.get_child_value(1).get_string();
            if (response.contains("Play")) {
                this.player.set_state("play");
            } else if (response.contains("Pause")) {
                this.player.set_state("pause");
            } else if (response.contains("Stop")) {
                this.player.set_state("stop");
            } else if (response.contains("Next")) {
//                this.player.play_next();
            } else if (response.contains("Previous")) {
//                this.player.play_previous();
            }
        });
    }
    private void _grab_media_player_keys() {
        try {
            this.proxy.call_sync("GrabMediaPlayerKeys",
                                 new GLib.Variant("(su)", "Music", 0),
                                 GLib.DBusCallFlags.NONE,
                                 -1,
                                 null);
        } catch (GLib.Error error) {
            print (error.message);
        }
    }
    private void add_actions() {
        var window = this.active_window as Gtk.ApplicationWindow;
        var filter = new Gtk.FileFilter();
        filter.set_filter_name("SoloWay Playlist");
        filter.add_pattern("*.swp");

        var open_file = new GLib.SimpleAction("open", null);
        open_file.activate.connect(() => {
            var chooser = new Gtk.FileChooserDialog ("Open playlist", window,
                Gtk.FileChooserAction.OPEN);
            chooser.add_buttons("_Cancel", Gtk.ResponseType.CANCEL,
                                "_Open", Gtk.ResponseType.ACCEPT, null);
            chooser.add_filter(filter);
            int id = chooser.run();
            if (id == Gtk.ResponseType.ACCEPT) {
                this.playlist_path = chooser.get_filename();
                window.activate_action("sync_with_file", null);
            }
            chooser.destroy();
        });
        var save_as = new GLib.SimpleAction("save_as", null);
        save_as.activate.connect(() => {
            var chooser = new Gtk.FileChooserDialog ("Save playlist", window,
                Gtk.FileChooserAction.SAVE);
            chooser.add_buttons("_Cancel", Gtk.ResponseType.CANCEL,
                                "_Save", Gtk.ResponseType.ACCEPT, null);
            chooser.add_filter(filter);
            int id = chooser.run();
            if (id == Gtk.ResponseType.ACCEPT) {
                this.playlist_path = chooser.get_filename();
                this.save_playlist(null);
            }
            chooser.destroy();
        });
        var sync_with_file = new GLib.SimpleAction("sync_with_file", null);
        sync_with_file.activate.connect(() => {
            var listBox = this.builder.get_object("playlist") as Gtk.ListBox;
            listBox.foreach((widget) => {
                widget.destroy(); //clean previous playlist
            });
            FileStream stream = FileStream.open(playlist_path, "r");
            assert(stream != null);
            string line = stream.read_line();
            if (line == "[playlist]") {
                while ((line = stream.read_line()) != null) {
                    string[] tmp = line.split("<=>");
                    var entry = new StreamEntry();
                    entry.title = tmp[0];
                    entry.uri = tmp[1];
                    entry.edit_btn.connect(show_entry_popover);
                    listBox.add(entry);
                }
            }
            listBox.show_all();
        });
        window.add_action(open_file);
        window.add_action(save_as);
        window.add_action(sync_with_file);
    }
    public void save_playlist(Gtk.Button? button) {
        FileStream stream = FileStream.open(playlist_path, "w");
        assert(stream != null);
        stream.puts("[playlist]\n");
        var listBox = this.builder.get_object("playlist") as Gtk.ListBox;
        listBox.foreach((widget) => {
            var row = widget as StreamEntry;
            stream.puts(row.title + "<=>" + row.uri + "\n");
        });
    }
    public void show_edit_button(Gtk.ListBox listBox) {
        var selected_row = listBox.get_selected_row();
        listBox.foreach((widget) => {
            var row = widget as StreamEntry;
            if (row != selected_row) {
                row.btn_show(false);
            } else {
                row.btn_show(true);
            }
        });
    }
    [CCode (instance_pos = -1)]
    public void play_stop_clicked(Gtk.ToggleButton button) {
        if (button.active) {
            this.player.set_state("play");
            ((Gtk.Image) this.builder.get_object("play-icon")).hide();
            ((Gtk.Image) this.builder.get_object("stop-icon")).show();
        } else {
            this.player.set_state("stop");
            ((Gtk.Image) this.builder.get_object("stop-icon")).hide();
            ((Gtk.Image) this.builder.get_object("play-icon")).show();
        }
    }
    public void play_active_row(Gtk.ListBox listBox, Gtk.ListBoxRow row) {
        var entry = row as StreamEntry;
        var button = this.builder.get_object("btn_play_stop") as Gtk.ToggleButton;
        if ((this.player.uri == entry.uri) && button.active) {
            this.headerBar.title = "SoloWay";
            //this.headerBar.subtitle = "";
            button.active = false;
        } else {
            this.player.uri = entry.uri;
            this.headerBar.title = entry.title;
            //this.headerBar.subtitle = entry.uri;
            button.active = false;
            button.active = true;
        }
        this.headerBar.subtitle = "";
    }
    //test
    private void song_title_changed_cb(string title) {
        int max_length = 50;
        if (title.length > max_length) {
            this.headerBar.subtitle = title.slice(0, max_length - 3) + "...";
        } else {
            this.headerBar.subtitle = title;
        }
        //var notify = new GLib.Notification(title);
        //this.send_notification("new-title", notify);
    }
    //test
    [CCode (instance_pos = -1)]
    public void show_song_title(Gtk.ToggleButton? button) {
        if (button.active == true) {
            var songPopover = new Gtk.Popover(button);
            var linkButton = new Gtk.LinkButton.with_label("https://google.com/search?q=" + player.title, player.title);
            if (player.title == null) {
                linkButton.label = "Unkown Artist and Song";
                linkButton.uri = "";
                linkButton.sensitive = false;
            }
            linkButton.activate_link.connect(() => {
                songPopover.hide();
                return false;
            });
            songPopover.add(linkButton);
            songPopover.show_all();
            songPopover.closed.connect((popover) => {
                button.active = false;
            });
        }
        var notification = new GLib.Notification("Some text");
        var app = GLib.Application.get_default();
        app.send_notification(null, notification);
    }
    [CCode (instance_pos = -1)]
    public void show_add_popover(Gtk.ToggleButton button) {
        if (button.active == true) {
            var popover = new EntryPopover(button, 250);
            var btnAdd = new Gtk.Button.with_mnemonic("_Add");

            btnAdd.get_style_context().add_class("suggested-action");
            btnAdd.halign = Gtk.Align.CENTER;
            btnAdd.clicked.connect((button) => {
                if (popover.uri.has_prefix("http")) {
                    var listBox = this.builder.get_object("playlist") as Gtk.ListBox;
                    var entry = new StreamEntry();
                    entry.title = popover.title;
                    entry.uri = popover.uri;
                    listBox.add(entry);
                    listBox.show_all();
                    popover.hide();
                } else {
                    return;
                }
            });
            popover.set_buttons(btnAdd);
            popover.closed.connect((popover) => {
                button.active = false;
            });
            popover.show_all();
        }
    }
    public void show_entry_popover(Gtk.ListBoxRow gtkRow, Gtk.Widget? widget) {
            var row = gtkRow as StreamEntry;
            if (widget == null) {
                widget = gtkRow as Gtk.Widget;
            }
            var popover = new EntryPopover(widget, 250);

            popover.title = row.title;
            popover.uri = row.uri;

            var btnEdit = new Gtk.Button.with_mnemonic("_Edit");
            btnEdit.get_style_context().add_class("suggested-action");
            btnEdit.clicked.connect((button) => {
                row.title = popover.title;
                row.uri = popover.uri;
                popover.hide();
            });

            var btnRemove = new Gtk.Button.with_mnemonic("_Remove");
            btnRemove.get_style_context().add_class("destructive-action");
            btnRemove.clicked.connect((button) => {
                row.destroy();
                popover.hide();
            });

            var bxButtons = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
            bxButtons.halign = Gtk.Align.CENTER;
            bxButtons.pack_start(btnRemove);
            bxButtons.pack_start(btnEdit);

            popover.set_buttons(bxButtons);
            popover.show_all();
    }
}
}
