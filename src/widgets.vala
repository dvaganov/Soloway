using Gtk;

public class SEntry : Gtk.ListBoxRow
{
    public string title {get; private set;}
    public string uri {get; private set;}
    
    public SEntry (string title, string uri)
    {
        this.title = title;
        this.uri = uri;
        this.height_request = 50;

        var label = new Gtk.Label (title);
        add (label);
    }
}

public class SHorizontalPanel : Gtk.Revealer
{
    private Gtk.Button _btn_play;
    private Gtk.Button _btn_stop;
    private Gtk.Button _btn_prev;
    private Gtk.Button _btn_next;
    private Gtk.Label _entry_info;
    private Gtk.Label _entry_title;
    
    public SHorizontalPanel () {
        
        var grid = new Gtk.Grid ();
        grid.margin = 10;
        grid.column_spacing = 10;
        add (grid);
        
        _entry_title = new Gtk.Label (null);
        _entry_title.use_markup = true;
        _entry_title.halign = Gtk.Align.START;
        _entry_title.ellipsize = Pango.EllipsizeMode.END;
        _entry_title.max_width_chars = 30;
        grid.attach (_entry_title, 1, 0);
        
        _entry_info = new Gtk.Label (null);
        _entry_info.halign = Gtk.Align.START;
        _entry_info.max_width_chars = 50;
        _entry_info.ellipsize = Pango.EllipsizeMode.END;
        _entry_info.set_selectable (true);
        _entry_info.justify = Gtk.Justification.LEFT;
        _entry_info.hexpand = true;
        grid.attach (_entry_info, 1, 1);
        
        var box = new Gtk.Box (Orientation.HORIZONTAL, 0);
        box.valign = Align.CENTER;
        box.halign = Align.CENTER;
        box.get_style_context ().add_class ("linked");
        grid.attach (box, 0, 0, 1, 2);
        
        _btn_next = new Gtk.Button.from_icon_name ("media-seek-forward-symbolic", IconSize.BUTTON);
        _btn_next.action_name = "app.next-entry";
        box.pack_end (_btn_next, false);
        
        _btn_prev = new Gtk.Button.from_icon_name ("media-seek-backward-symbolic", IconSize.BUTTON);
        _btn_prev.action_name = "app.prev-entry";
        box.pack_start (_btn_prev, false);
        
        _btn_play = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", IconSize.BUTTON);
        _btn_play.width_request = 60;
        _btn_play.action_name = "app.change-state";
        box.pack_start (_btn_play);
        
        _btn_stop = new Gtk.Button.from_icon_name ("media-playback-stop-symbolic", IconSize.BUTTON);
        _btn_stop.width_request = 60;
        _btn_stop.action_name = "app.change-state";
        _btn_stop.no_show_all = true;
        box.pack_start (_btn_stop);
    }
    public void change_state_to_play (bool is_playing)
    {
        if (is_playing)
        {
            _btn_play.hide ();
            _btn_stop.show ();
        }
        else
        {
            _btn_stop.hide ();
            _btn_play.show ();
        }
    }
    public void change_title (string title)
    {
        _entry_title.label = "<b>" + title + "</b>";
    }
    public void change_info (string info)
    {
        _entry_info.label = info;
    }
}

public class SSidePanel : Gtk.Revealer
{
    private Gtk.Entry _ent_title;
    private Gtk.Entry _ent_uri;
    private Gtk.Button _btn_add;
    private Gtk.Button _btn_edit;
    
    public SSidePanel ()
    {
        transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
        valign = Gtk.Align.CENTER;
        
        var grid = new Gtk.Grid ();
        grid.margin = 5;
        grid.row_spacing = 10;
        add (grid);
        
        var lbl_title = new Gtk.Label ("Title:");
        grid.attach (lbl_title, 0, 0);
        
        _ent_title = new Gtk.Entry ();
        grid.attach (_ent_title, 0, 1);
        
        var lbl_uri = new Gtk.Label ("URL:");
        grid.attach (lbl_uri, 0, 2);
        
        _ent_uri = new Gtk.Entry ();
        _ent_uri.changed.connect ((editable) =>
        {
            var entry = editable as Gtk.Entry;
            if (entry.text.has_prefix ("http://") || entry.text.has_prefix ("https://"))
            {
                _btn_add.sensitive = true;
                _btn_edit.sensitive = true;
            }
            else
            {
                _btn_add.sensitive = false;
                _btn_edit.sensitive = false;
            }
        });
        grid.attach (_ent_uri, 0, 3);
        
        _btn_add = new Gtk.Button.with_mnemonic("_Add");
        _btn_add.get_style_context().add_class("suggested-action");
        _btn_add.sensitive = false;
        _btn_add.no_show_all = true;
        grid.attach (_btn_add, 0, 4);
        
        _btn_edit = new Gtk.Button.with_mnemonic("_Edit");
        _btn_edit.get_style_context().add_class("suggested-action");
        _btn_edit.sensitive = false;
        _btn_edit.no_show_all = true;
        grid.attach (_btn_edit, 0, 4);
    }
    public void show_panel (SEntry? entry = null)
    {
        if (reveal_child == false)
        {
            if (entry == null)
            {
                _ent_title.text = "";
                _ent_uri.text = "";
                _btn_add.show ();
                _btn_edit.hide ();
            }
            else
            {
                _ent_title.text = entry.title;
                _ent_uri.text = entry.uri;
                _btn_add.hide ();
                _btn_edit.show ();
            }
            reveal_child = true;
        }
        else if (reveal_child == true)
        {
            reveal_child = false;
        }
    }
}
