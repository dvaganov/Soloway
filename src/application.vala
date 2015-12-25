using Gtk;

public class SApplication : Gtk.Application
{
    private SWindow _win;
    private SPlayer _player;
    private string _playlist_path;
    
    public SApplication (string[] args)
    {
        Object(application_id: "home.dvaganov.soloway21");
        _player = new SPlayer (args);
    }
    protected override void activate ()
    {
        _create_actions ();
        
        var menu = new GLib.Menu ();
        menu.append ("Change State", "app.change-state");
        menu.append ("Quit", "app.quit");
        app_menu = menu;
        
        _win = new SWindow (800, 600);
        _win.on_row_activate.connect (_player.change_state);
        
        _player.on_state_change.connect (_win.change_btn_state_to_play);
        _player.on_info_change.connect (_win.change_panel_info);
        
        add_window (_win);
        
        _playlist_path = "/home/dvaganov/Documents/Programming/Vala/SoloWay/saved.swp";
        _create_playlist ();
        
//        _set_mediakeys ();
        
        _win.show_all();
    }
    private void _create_actions ()
    {
        var action = new SimpleAction ("change-state", null);
        action.activate.connect (() =>
        {
            _player.change_state ();
        });
        add_action (action);
        
        action = new SimpleAction ("next-entry", null);
        action.activate.connect (() =>
        {
            _win.activate_next_row ();
        });
        add_action (action);
        
        action = new SimpleAction ("prev-entry", null);
        action.activate.connect (() =>
        {
            _win.activate_prev_row ();
        });
        add_action (action);
        
        action = new SimpleAction ("quit", null);
        action.activate.connect (this.quit);
        add_action (action);
    }
    private void _create_playlist ()
    {
        if (_playlist_path != null)
        {
            _win.clean_playlist ();
            
            var stream = FileStream.open(_playlist_path, "r");
            assert(stream != null);
            
            var line = stream.read_line();
            if (line == "[playlist]")
            {
                while ((line = stream.read_line()) != null)
                {
                    string[] entry = line.split("<=>");
                    _win.add_entry (entry[0], entry[1]);
                }
            }
        }
    }
//    private void _set_mediakeys () {
//        DBusProxy proxy = null;
//        try
//        {
//            proxy = new DBusProxy.sync (GLib.Bus.get_sync (GLib.BusType.SESSION, null),
//                                        GLib.DBusProxyFlags.NONE,
//                                        null,
//                                        "org.gnome.SettingsDaemon",
//                                        "/org/gnome/SettingsDaemon/MediaKeys",
//                                        "org.gnome.SettingsDaemon.MediaKeys",
//                                        null);
//        }
//        catch (GLib.Error err)
//        {
//            print (err.message);
//        }
//        proxy.g_signal.connect ((proxy, sender, sig_name, parameters) =>
//        {
//            if (sig_name != "MediaPlayerKeyPressed") {
//                print ("Received an unexpected signal %s from media player".printf(sig_name));
//                return;
//            }
//            var response = parameters.get_child_value(1).get_string();
//            if (response.contains("Play"))
//            {
//                this.activate_action ("change-state", null);
//            } 
//            else if (response.contains("Pause"))
//            {
//                this.activate_action ("change-state", null);
//            }
//            else if (response.contains("Stop"))
//            {
//                this.activate_action ("change-state", null);
//            }
//            else if (response.contains("Next"))
//            {
//                this.activate_action ("next-entry", null);
//            }
//            else if (response.contains("Previous"))
//            {
//                this.activate_action ("prev-entry", null);
//            }
//        });
//        try
//        {
//            proxy.call_sync ("GrabMediaPlayerKeys",
//                             new GLib.Variant("(su)", "Music", 0),
//                             GLib.DBusCallFlags.NONE,
//                             -1,
//                             null);
//        }
//        catch (GLib.Error error)
//        {
//            print (error.message);
//        }
//    }
    public static int main (string[] args)
    {
        var app = new SApplication (args);
        return app.run (args);
    }
}
