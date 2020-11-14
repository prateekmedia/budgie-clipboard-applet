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

  public static bool attach_monitor_clipboard() {
      monitor_clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);
      monitor_clipboard.owner_change.connect ((ev) => {
        ClipboardManagerApplet.ClipboardManagerPopover.addRow(0);
      });
      monitor_clipboard_selection = Gtk.Clipboard.get (Gdk.SELECTION_PRIMARY);
      monitor_clipboard_selection.owner_change.connect ((ev) => {
        bool select_clip = ClipboardManagerApplet.Applet.setting.get_boolean("selectclip");
        if(select_clip){
          ClipboardManagerApplet.ClipboardManagerPopover.addRow(1);
        }
      });
      return false;
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

    public ClipboardManagerSettings(GLib.Settings? settings) {
        // Gtk stuff, widgets etc. here

        //History Label
      //  copyselected =  Applet.setting.get_boolean("copyselected");
        Label historyLabel = new Gtk.Label("History Size");
        historyLabel.set_halign (Gtk.Align.START);
        historyLabel.set_hexpand (true);
        SpinButton historySpin = new Gtk.SpinButton.with_range (2, 100, 1);
        historySpin.set_value(settings.get_int("historylength"));
        historySpin.set_halign (Gtk.Align.END);
        historySpin.set_hexpand (true);

        //Get Selection on Clipboard
        Label selClipLabel = new Gtk.Label("Get Selection to Clipboard");
        selClipLabel.set_halign (Gtk.Align.START);
        selClipLabel.set_hexpand (true);
        Switch selClipTggle = new Gtk.Switch();
        selClipTggle.set_active(settings.get_boolean("selectclip"));
        selClipTggle.set_halign (Gtk.Align.END);
        selClipTggle.set_hexpand (true);

        //Copy selection to Clipboard
        Label copySelLabel = new Gtk.Label("Copy Selection to Clipboard");
        copySelLabel.set_halign (Gtk.Align.START);
        copySelLabel.set_hexpand (true);
        Switch copySelTggle = new Gtk.Switch();
        copySelTggle.set_active(settings.get_boolean("copyselected"));
        copySelTggle.set_sensitive (false);
        if(settings.get_boolean("selectclip") == true){
          copySelTggle.set_sensitive (true);
        }
        copySelTggle.set_halign (Gtk.Align.END);
        copySelTggle.set_hexpand (true);

        attach (historyLabel,   0, 0, 1, 1);
        attach (historySpin,    1, 0, 1, 1);
        attach (selClipLabel,   0, 1, 1, 1);
        attach (selClipTggle,   1, 1, 1, 1);
        attach (copySelLabel,   0, 2, 1, 1);
        attach (copySelTggle,   1, 2, 1, 1);

        historySpin.value_changed.connect (()=>{
          int curr_val = historySpin.get_value_as_int();
          if(ClipboardManagerPopover.HISTORY_LENGTH != curr_val){
            settings.set_int("historylength" , curr_val);
            ClipboardManagerPopover.HISTORY_LENGTH = curr_val;
            ClipboardManagerPopover.update_pager();
            //  ClipboardManagerPopover.nav_visible();

          }
        });

        selClipTggle.state_set.connect (()=>{
          bool curr_act = selClipTggle.get_active();
          settings.set_boolean("selectclip" , curr_act);
          if(curr_act){
            copySelTggle.set_sensitive (true);
          } else {
            copySelTggle.set_sensitive (false);
          }
          return false;
        });

        copySelTggle.state_set.connect (()=>{
          bool curr_act = copySelTggle.get_active();
          settings.set_boolean("copyselected" , curr_act);
          ClipboardManagerPopover.copyselected = curr_act;
          return false;
        });
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
    public static Box mainContent = new Box(Gtk.Orientation.VERTICAL, 0);
    public static Entry search_box = new Gtk.Entry ();
    public static Box scrbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    public static ListBox realContent = new ListBox();
    public static Box navContainer = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    public static Box navbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    public static ListBox setContent = new ListBox();
    public static Label pager = new Gtk.Label(null);
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
      scrbox.add(realContent);
      mainContent.add(search_box);
      mainContent.add(scrbox);
      mainContent.add(navContainer);
      mainContent.add(setContent);

      nav_visible();

      search_box.set_placeholder_text("Type here to search....");

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
      pager.set_label(@"$(history.length)/$HISTORY_LENGTH");
      pager.set_halign (Gtk.Align.CENTER);
      setContent.prepend(pager);
    }

    public static void addRow(int ttype){
      text = ClipboardManager.get_clipboard_text();
      if (ttype==0) { text = ClipboardManager.get_clipboard_text(); } 
      else if (ttype ==1 ) { text = ClipboardManager.get_selected_text(); } 
      else if (ttype ==2) { 
        if (text == null || text.strip().length ==0){
          text = "Clipboard is Currently Empty!";
        } else {
            ttyped = 1;
        }
       } 
      else { text = ""; }
      if (history.index (0) != text || specialMark == 0){
        if (text.strip().length != 0 && text != null) {
          if (ttype >=0 && ttype <=1 || ttyped==1){
            realContent.destroy();
            scrbox.add(realContent);
            search_box.preedit_changed.connect (on_search_activate);
            if (!row_activated_flag){
              for (int j = 0; j < history.length; j++){
                if(text == history.index(j)){
                  history.remove_index(j);
                  break;
                }
              }
              update_history(text);
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
              if(j>=10){
                break;
              }
              text = history.index(j);
              text = text.replace("\n", " ").strip();
              if (text.length >30){
                text = text.substring(0,30) + "...";
              }
              int copy = j;
              Box btnlist = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
              Box thislist = btnlist;
              Button clipMgr = new Button();
              Button dismissbtn = new Button();
              Label dissLabel = new Label("X");
              dismissbtn.add(dissLabel);
              Label clipMgrLabel = new Label(text);
              if (specialMark ==j){
                clipMgrLabel.set_label(@"<i><b><u>$text</u></b></i>");
                clipMgrLabel.use_markup = true;
              }
              clipMgrLabel.set_xalign(0);
              clipMgr.add(clipMgrLabel);
              clipMgr.set_hexpand(true);
              print(@"$j =>  $(history.index (j)) \n");
              rows.append_val(text);
              dismissbtn.clicked.connect(()=>{
                thislist.destroy();
                history.remove_index (copy);
              });
              clipMgr.clicked.connect(()=>__on_row_activated(copy));
              btnlist.add(clipMgr);
              btnlist.add(dismissbtn);
              realContent.add(btnlist);
            }
          } else {
            Label clipMgrLabel = new Label(text);
            realContent.add(clipMgrLabel);
          }
          update_pager();
          Applet.popover.get_child().show_all();
        }
      }
    }

    public static void remove_row(){
      if (history.length >0){
        realContent.destroy();
        scrbox.add(realContent); 
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
        update_pager();
        Applet.popover.get_child().show_all();
      }
    }

    public static void update_history(string item){
      history.prepend_val (text);
      if (history.length > HISTORY_LENGTH){
        if(history.length == HISTORY_LENGTH+1){
          history.remove_index (HISTORY_LENGTH);
        } else{
          history.remove_range(HISTORY_LENGTH-1 , history.length - HISTORY_LENGTH);
        }
      }
    }
    public static void update_pager(){
      pager.destroy();
      pager.set_label(@"$(history.length)/$HISTORY_LENGTH");
      pager.set_halign (Gtk.Align.CENTER);
      setContent.prepend(pager);
      Applet.popover.get_child().show_all();
    }
    public static void nav_visible(){
      navbox.destroy();
      navbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
      navContainer.add(navbox);
      Label prvNavLabel = new Gtk.Label("⟵");
      Button prvBtn = new Button();
      //  prvBtn.clicked.connect(remove_row);
      prvNavLabel.set_halign (Gtk.Align.CENTER);
      prvNavLabel.set_hexpand (true);
      Label pageNo = new Gtk.Label(@"1/1");
      pageNo.set_halign (Gtk.Align.CENTER);
      Label nxtNavLabel = new Gtk.Label("⟶");
      Button nxtBtn = new Button();
      nxtNavLabel.set_halign (Gtk.Align.CENTER);
      nxtNavLabel.set_hexpand (true);

      prvBtn.add(prvNavLabel);
      nxtBtn.add(nxtNavLabel);

      navbox.add(prvBtn);
      navbox.add(pageNo);
      navbox.add(nxtBtn);
    }
    public static void on_search_activate (string name) {
      print (@"\nHello $name!\n\n");
    }
    public static void __on_row_activated(int copy){
      row_activated_flag = true;
      ClipboardManager.set_text(history.index(copy));
      Applet.popover.hide();
      specialMark = copy;
    }

  }

  public class Applet: Budgie.Applet {
    private Gtk.EventBox indicatorBox;
    public static ClipboardManagerPopover popover = null;
    private unowned Budgie.PopoverManager ? manager = null;
    public static GLib.Settings setting = new GLib.Settings("com.prateekmedia.clipboardmanager");
    public string uuid { public set; public get; }
    /* specifically to the settings section */
    public override bool supports_settings() {
      return true;
    }
    public override Gtk.Widget ? get_settings_ui() {
      return new ClipboardManagerSettings(setting);
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
      ClipboardManager.attach_monitor_clipboard();
      popover.get_child().show_all();
      show_all();
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