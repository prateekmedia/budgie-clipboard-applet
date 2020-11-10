using Gtk;

/*
 * Clipboard Manager
 *
 * Copyright © 2020 Prateek SU
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 */

 public class ClipboardManager : Object {
    /*
  * Here we keep the (possibly) shared stuff, or general functions, to
  * keep the main code clean and readable
  */
  private static Gtk.Clipboard monitor_clipboard;
  private static Gtk.Clipboard monitor_clipboard_selection;
  //  int HISTORY_LENGTH = 10;
  //  string ? [] history;
  //  string ? [] rows;
  //  bool row_activated_flag = false;

  public static bool attach_monitor_clipboard() {
      monitor_clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);
      monitor_clipboard_selection = Gtk.Clipboard.get (Gdk.SELECTION_PRIMARY);
      monitor_clipboard.owner_change.connect ((ev) => {
        //add text        
        ClipboardManagerApplet.ClipboardManagerPopover.addRow(0);
      });
      monitor_clipboard_selection.owner_change.connect ((ev) => {
        //add text
        ClipboardManagerApplet.ClipboardManagerPopover.addRow(1);
      });
      return true;
  }

  public static string get_selected_text () {
      var clipboard = Gtk.Clipboard.get (Gdk.SELECTION_PRIMARY);
      string text = clipboard.wait_for_text ();
      return text;
  }
  
  public static string get_clipboard_text () {
      var clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);
      string text = clipboard.wait_for_text ();
      return text;
  }
  public static void set_text (string text) {
      var clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);
      clipboard.set_text (text, text.length);
  }
}

namespace ClipboardManagerApplet {

  public class ClipboardManagerSettings: Gtk.Grid {
    /* Budgie Settings -section */
    //  GLib.Settings ? settings = null

    public ClipboardManagerSettings(GLib.Settings ? settings) {
	      // Gtk stuff, widgets etc. here
    }
  }

  public class Plugin: Budgie.Plugin,
  Peas.ExtensionBase {
    public Budgie.Applet get_panel_widget(string uuid) {
      return new Applet();
    }
  }

  public class ClipboardManagerPopover: Budgie.Popover {
    private EventBox indicatorBox;
    private Image indicatorIcon;
    public static Clipboard clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD);
    public static ListBox mainContent = new ListBox();
    public static string text;
    /* process stuff */
    /* GUI stuff */
    /* misc stuff */

    public ClipboardManagerPopover(Gtk.EventBox indicatorBox) {
      Object(relative_to: indicatorBox);

      this.indicatorBox = indicatorBox;

      indicatorIcon = new Gtk.Image.from_icon_name("clipboard-text-outline-symbolic", Gtk.IconSize.MENU);
      indicatorBox.add(this.indicatorIcon);

      /* gsettings stuff */

      /* box */
      add(mainContent);
      string text = "Clipboard is Currently EMPTY!";
      Button clipMgr = new Button();
      Label clipMgrLabel = new Label(null);
      clipMgrLabel.set_text(text);
      clipMgrLabel.set_max_width_chars(30);
      clipMgr.add(clipMgrLabel);
      mainContent.add(clipMgr);
    }

    public static void addRow(int ttype){
      if (ttype==0) {
        text = ClipboardManager.get_clipboard_text();
      } else if (ttype ==1 ) {
        text = ClipboardManager.get_selected_text();
      } else {
        text = "";
      }
      print(text);
      Button clipMgr = new Button();
      Label clipMgrLabel = new Label(text);
      clipMgrLabel.set_max_width_chars(30);
      clipMgr.add(clipMgrLabel);
      mainContent.add(clipMgr);
      popover.get_child().show_all();
      show_all();
    }

  }

  public class Applet: Budgie.Applet {
    private Gtk.EventBox indicatorBox;
    private ClipboardManagerPopover popover = null;
    private unowned Budgie.PopoverManager ? manager = null;
    public string uuid { public set; public get; }
    /* specifically to the settings section */
    public override bool supports_settings() {
      return true;
    }
    public override Gtk.Widget ? get_settings_ui() {
      return new ClipboardManagerSettings(this.get_applet_settings(uuid));
    }

    public Applet() {
      /* box */
      indicatorBox = new Gtk.EventBox();
      add(indicatorBox);
      /* Popover */
      popover = new ClipboardManagerPopover(indicatorBox);
      /* On Press indicatorBox */
      indicatorBox.button_press_event.connect((e) =>{
        if (e.button != 1) {
          return Gdk.EVENT_PROPAGATE;
        }
        if (popover.get_visible()) {
          popover.hide();
        } else {
          this.manager.show_popover(indicatorBox);
        }
        return Gdk.EVENT_STOP;
      });
      ClipboardManager.attach_monitor_clipboard();
      popover.get_child().show_all();
      show_all();
      //  Timeout.add( 1, ClipboardManager.attach_monitor_clipboard);
    }
    public override void update_popovers(Budgie.PopoverManager ? manager) {
      this.manager = manager;
      manager.register_popover(indicatorBox, popover);
    }
  }
}

[ModuleInit]
public void peas_register_types(TypeModule module) {
  /* boilerplate - all modules need this */
  var objmodule = module as Peas.ObjectModule;
  objmodule.register_extension_type(typeof(Budgie.Plugin), typeof(ClipboardManagerApplet.Plugin));
}