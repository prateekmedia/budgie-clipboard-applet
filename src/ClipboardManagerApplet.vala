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

  public static bool attach_monitor_clipboard(bool sclip) {
      monitor_clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);
      monitor_clipboard.owner_change.connect ((ev) => {
        //add text        
        ClipboardManagerApplet.ClipboardManagerPopover.addRow(0);
      });
      if (sclip){
        monitor_clipboard_selection = Gtk.Clipboard.get (Gdk.SELECTION_PRIMARY);
        monitor_clipboard_selection.owner_change.connect ((ev) => {
          //add text
          ClipboardManagerApplet.ClipboardManagerPopover.addRow(1);
        });
      }
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
  public static void set_text (string? item) {
      //  string text = button.get_label();
      //  string item = ClipboardManagerApplet.ClipboardManagerPopover.history.index (j);
      var clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);
      if (item != clipboard.wait_for_text ()){
        clipboard.set_text (item, item.length);
      }
  }
}

namespace ClipboardManagerApplet {

  public class ClipboardManagerSettings: Gtk.Grid {
    /* Budgie Settings -section */
    //  GLib.Settings ? settings = null

    public ClipboardManagerSettings(GLib.Settings ? settings) {
        // Gtk stuff, widgets etc. here
        Label newLabel = new Gtk.Label("This is a sample label");
        add(newLabel);
    }
  }

  public class Plugin: Budgie.Plugin,
  Peas.ExtensionBase {
    public Budgie.Applet get_panel_widget(string uuid) {
      return new Applet();
    }
  }

  public class ClipboardManagerPopover: Budgie.Popover {
    public static EventBox indicatorBox;
    public static Image indicatorIcon;
    public static Clipboard clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD);
    public static ListBox mainContent = new ListBox();
    public static ListBox realContent = new ListBox();
    public static ListBox setContent = new ListBox();
    public static string text;
    public static bool copyselected =  Applet.setting.get_boolean("copyselected");
    public static int HISTORY_LENGTH = Applet.setting.get_int("historylength");
    public static Array<string> history = new Array<string> ();
    public static Array<string> rows = new Array<string> ();
    public static bool row_activated_flag = false;
    public static int idx;
    public static int ttyped = 0;
    public static int specialMark = 0;
    /* process stuff */
    /* GUI stuff */
    /* misc stuff */

    public ClipboardManagerPopover(Gtk.EventBox indicatorBox) {
      Object(relative_to: indicatorBox);

      indicatorIcon = new Gtk.Image.from_icon_name("clipboard-outline-symbolic", Gtk.IconSize.MENU);
      indicatorBox.add(indicatorIcon);

      /* gsettings stuff */

      /* box */
      add(mainContent);
      mainContent.add(realContent);
      mainContent.add(setContent);
      string settitext = "-------------------------------------";
      Label setMgrLabel = new Label(@"$settitext");
      setContent.add(setMgrLabel);      

      string emptyCliptext = "Empty Clipboard ";
      Button emptyClip = new Button();
      emptyClip.clicked.connect(remove_row);
      Label emptyClipLabel = new Label(@"<b>$emptyCliptext</b>");
      emptyClipLabel.set_xalign(0);
      emptyClipLabel.use_markup = true;
      emptyClip.add(emptyClipLabel);
      setContent.add(emptyClip);
    }

    public static void addRow(int ttype){
      text = ClipboardManager.get_clipboard_text();
      if (ttype==0) { text = ClipboardManager.get_clipboard_text(); } 
      else if (ttype ==1 ) { text = ClipboardManager.get_selected_text(); } 
      else if (ttype ==2) { 
        if (text.strip().length == 0 || text == null){
          text = "Clipboard is Currently Empty!";
        } else {
            text = ClipboardManager.get_clipboard_text();
            ttyped = 1;
        }
       } 
      else { text = ""; }
      if (history.index (0) != text){
        if (text.strip().length != 0 && text != null) {
          if (ttype >=0 && ttype <=1 || ttyped==1){
            realContent.destroy();
            mainContent.prepend(realContent);
            if (!row_activated_flag){
              for (int j = 0; j < history.length; j++){
                if(text == history.index(j)){
                  history.remove_index(j);
                  break;
                }
              }
              update_handler(text);
              specialMark = 0;
            }
            if (copyselected && ttype ==1){
              ClipboardManager.set_text(text);
            }
            row_activated_flag = false;
          }
          if (ttype !=2 || ttyped==1) {
            if (history.length ==1){
              indicatorIcon.set_from_icon_name("clipboard-text-outline-symbolic", Gtk.IconSize.MENU);
            }
            for (int j = 0; j < history.length; j++) {
              text = history.index(j);
              text = text.replace("\n", " ").strip();
              if (text.length >30){
                text = text.substring(0,30) + "...";
              }
              int copy = j;
              Button clipMgr = new Button();
              Label clipMgrLabel = new Label(text);
              if (specialMark ==j){
                clipMgrLabel.set_label(@"<i><b><u>$text</u></b></i>");
                clipMgrLabel.use_markup = true;
              }
              clipMgrLabel.set_xalign(0);
              clipMgr.add(clipMgrLabel);
              print(@"$j =>  $(history.index (j)) \n");
              rows.append_val(text);
              clipMgr.clicked.connect(()=>__on_row_activated(copy));
              realContent.add(clipMgr);
            }
          } else {
            Label clipMgrLabel = new Label(text);
            realContent.add(clipMgrLabel);
          }
          Applet.popover.get_child().show_all();
        }
      }
    }

    public static void remove_row(){
      if (history.length >0){
        realContent.destroy();
        mainContent.prepend(realContent); 
        history.remove_range(0, history.length);
        indicatorIcon.set_from_icon_name("clipboard-outline-symbolic", Gtk.IconSize.MENU);
        Applet.popover.hide();
        ClipboardManager.set_text("");
        string text = "Clipboard is Currently Empty!";
        Label currLabel = new Label(text);
        realContent.add(currLabel);
        for (int i = 0; i < history.length ; i++) {
          print ("%s\n", history.index (i));
        }
        Applet.popover.get_child().show_all();
      }
    }

    public static void update_history(string item){
      history.prepend_val (text);
      if (history.length > HISTORY_LENGTH){
          history.remove_index (HISTORY_LENGTH);
      }
    }
    public static void update_handler(string item){
      update_history(item);
    }
    public static void __on_row_activated(int copy){
      row_activated_flag = true;
      ClipboardManager.set_text(history.index(copy));
      Applet.popover.hide();
      specialMark = copy;
    }
    public static string insert_row(){
      return "";
    }
    public static void __update_ui(string item){
      int j =0;
      while (j < history.length) {
        print(history.index (j));
        j++;
      }

    }

  }

  public class Applet: Budgie.Applet {
    private Gtk.EventBox indicatorBox;
    public static ClipboardManagerPopover popover = null;
    private unowned Budgie.PopoverManager ? manager = null;
    public static GLib.Settings setting = new GLib.Settings("com.prateekmedia.clipboardmanager");
    //  public static bool select_clip = false;
    public static bool select_clip = setting.get_boolean("selectclip");
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
      ClipboardManagerPopover.addRow(2);
      ClipboardManager.attach_monitor_clipboard(select_clip);
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
