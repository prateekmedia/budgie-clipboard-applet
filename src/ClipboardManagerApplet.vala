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
        if(!ClipboardManagerApplet.ClipboardManagerPopover.primode){
        Array<string> history = ClipboardManagerApplet.ClipboardManagerPopover.history;
        string text = get_clipboard_text();
        if (text.strip().length != 0 && text != null){
          if( text !=history.index(0)){
            ClipboardManagerApplet.ClipboardManagerPopover.addRow(0);
        }}}
      });
      monitor_clipboard_selection = Gtk.Clipboard.get (Gdk.SELECTION_PRIMARY);
      monitor_clipboard_selection.owner_change.connect ((ev) => {
        if(!ClipboardManagerApplet.ClipboardManagerPopover.primode){
        Array<string> history = ClipboardManagerApplet.ClipboardManagerPopover.history;
        bool select_clip = ClipboardManagerApplet.Applet.settings.get_boolean("selectclip");
        string text = get_selected_text();
        if (select_clip && text != null && text.strip().length != 0 ){
          if(text.contains(history.index(0))){
            history.remove_index(0);
          }
          if( text !=history.index(0)){
            ClipboardManagerApplet.ClipboardManagerPopover.addRow(1);
          }
        }}
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
      if (item != null &&item != clipboard.wait_for_text ()){
        clipboard.set_text (item, item.length);
      }
  }
}

namespace ClipboardManagerApplet {

  public class ClipboardManagerSettings: Gtk.Grid {
    /* Budgie Settings -section */

    public ClipboardManagerSettings(GLib.Settings? settings) {
        // Gtk stuff, widgets etc. here

        //History Label
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

        //Page Size Label
        Label pgeSizeLabel = new Gtk.Label("Page Size");
        pgeSizeLabel.set_halign (Gtk.Align.START);
        pgeSizeLabel.set_hexpand (true);
        SpinButton pgeSizeSpin = new Gtk.SpinButton.with_range (2, 100, 1);
        pgeSizeSpin.set_value(settings.get_int("pagesize"));
        pgeSizeSpin.set_halign (Gtk.Align.END);
        pgeSizeSpin.set_hexpand (true);

        //Mininal Interface
        Label minIntLabel = new Gtk.Label("Minimal Interface(Requires Logout)");
        minIntLabel.set_halign (Gtk.Align.START);
        minIntLabel.set_hexpand (true);
        Switch minIntTggle = new Gtk.Switch();
        minIntTggle.set_active(settings.get_boolean("minimalinterface"));
        minIntTggle.set_halign (Gtk.Align.END);
        minIntTggle.set_hexpand (true);

        attach (historyLabel,   0, 0, 1, 1);
        attach (historySpin,    1, 0, 1, 1);
        attach (selClipLabel,   0, 1, 1, 1);
        attach (selClipTggle,   1, 1, 1, 1);
        attach (copySelLabel,   0, 2, 1, 1);
        attach (copySelTggle,   1, 2, 1, 1);
        attach (pgeSizeLabel,   0, 3, 1, 1);
        attach (pgeSizeSpin,    1, 3, 1, 1);
        attach (minIntLabel,    0, 4, 1, 1);
        attach (minIntTggle,    1, 4, 1, 1);

        historySpin.value_changed.connect (()=>{
          int curr_val = historySpin.get_value_as_int();
          if(ClipboardManagerPopover.HISTORY_LENGTH != curr_val){
            settings.set_int("historylength" , curr_val);
            ClipboardManagerPopover.HISTORY_LENGTH = curr_val;
            ClipboardManagerPopover.update_pager();
            Applet.popover.get_child().show_all();
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

        pgeSizeSpin.value_changed.connect (()=>{
          int curr_val = pgeSizeSpin.get_value_as_int();
          if(ClipboardManagerPopover.maxPageitems != curr_val){
            settings.set_int("pagesize" , curr_val);
            ClipboardManagerPopover.maxPageitems = curr_val;
            Applet.popover.get_child().show_all();

          }
        });

        minIntTggle.state_set.connect (()=>{
          bool curr_act = minIntTggle.get_active();
          settings.set_boolean("minimalinterface" , curr_act);
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
    public static GLib.Settings settings = Applet.settings;
    public static Box mainContent = new Box(Gtk.Orientation.VERTICAL, 0);
    public static Box search_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    public static Entry search_box = new Gtk.Entry ();
    public static Button search_btn;
    public static Box scrbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    public static ListBox realContent = new ListBox();
    public static Box space = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    public static ListBox spacerCont = new Gtk.ListBox ();
    public static Box navContainer = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    public static Box navbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    public static Box editMode = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    public static Box privateMode = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    public static bool edMode = settings.get_boolean("editmode");
    public static bool primode = settings.get_boolean("privatemode");
    public static ListBox setContent = new ListBox();
    public static ListBox pagerCont = new Gtk.ListBox ();
    public static Label pager = new Gtk.Label(null);
    public static string text;
    public static bool copyselected =  settings.get_boolean("copyselected");
    public static bool minimalinterface =  settings.get_boolean("minimalinterface");
    public static int HISTORY_LENGTH = settings.get_int("historylength");
    public static Array<string> history = new Array<string> ();
    public static Array<Gtk.ListBox> listbax = new Array<Gtk.ListBox> ();
    public static bool row_activated_flag = false;
    public static bool private_mode = false;
    public static int idx;
    public static int pageNav = 0;
    public static int maxPageitems = settings.get_int("pagesize");
    public static int currPage = 1;
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
      if (!minimalinterface){
        mainContent.add(search_container);
        mainContent.add(space);
        mainContent.add(scrbox);
        mainContent.add(spacerCont);
        mainContent.add(navContainer);
        mainContent.add(setContent);
        
        string spaceT = "                                     ";
        Label spaceLab = new Label(@"$spaceT");
        space.add(spaceLab);  
        space.set_sensitive (false);    

        string spacerText = "-------------------------------------";
        Label spacerLabel = new Label(@"$spacerText");
        spacerCont.add(spacerLabel);      
        spacerCont.set_sensitive (false);
  
  	setContent.add(pagerCont);
  	  
        string emptyCliptext = "Empty Clipboard ";
        Button emptyClip = new Button();
        emptyClip.clicked.connect(remove_row);
        Label emptyClipLabel = new Label(@"<b>$emptyCliptext</b>");
        emptyClipLabel.set_xalign(0);
        emptyClipLabel.use_markup = true;
        emptyClip.add(emptyClipLabel);
        setContent.add(emptyClip);
  
        update_pager();
        
        Label editModeLabel = new Gtk.Label("   Edit Mode");
        editModeLabel.set_halign (Gtk.Align.START);
        editModeLabel.set_hexpand (true);
        Switch editModeTggle = new Gtk.Switch();
        editModeTggle.set_active(settings.get_boolean("editmode"));
        editModeTggle.set_halign (Gtk.Align.END);
        editModeTggle.set_hexpand (true);
  
        editModeTggle.state_set.connect (()=>{
          bool curr_act = editModeTggle.get_active();
          settings.set_boolean("editmode" , curr_act);
          edMode = curr_act;
          return false;
        });
  
        editMode.set_tooltip_text("Enabling this will add Cross icon to delete Clipboard Contents");
        editMode.add(editModeLabel);
        editMode.add(editModeTggle);
  
        setContent.add(editMode);
  
        Label privateModeLabel = new Gtk.Label("   Private Mode");
        privateModeLabel.set_halign (Gtk.Align.START);
        privateModeLabel.set_hexpand (true);
        Switch privateModeTggle = new Gtk.Switch();
        privateModeTggle.set_active(settings.get_boolean("privatemode"));
        privateModeTggle.set_halign (Gtk.Align.END);
        privateModeTggle.set_hexpand (true);
  
        privateModeTggle.state_set.connect (()=>{
          bool curr_act = privateModeTggle.get_active();
          settings.set_boolean("privatemode" , curr_act);
          primode = curr_act;
          return false;
        });
  
        privateMode.set_tooltip_text("Enabling this will stop Clipboard Manager to save any Clips");
        privateMode.add(privateModeLabel);
        privateMode.add(privateModeTggle);
        setContent.add(privateMode);
      }
      else {
        mainContent.add(search_container);
        mainContent.add(scrbox);
        mainContent.add(navContainer);
      }   

      search_box.set_placeholder_text("Search Clipboard....");
      search_box.set_hexpand(true);
      search_btn = new Button.from_icon_name("search");
      search_btn.clicked.connect(()=>{
        text = search_box.get_text();
        if (text != null && text.strip().length != 0 && history.length !=0){
          on_search_activate(search_box);
        }});
      search_container.add(search_box);
      search_container.add(search_btn);
    }

    public static void addRow(int ttype){
      pageNav = 0;
      if (!row_activated_flag){
        currPage =1;
      }
      listbax = new Array<Gtk.ListBox>();
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
      if (ttype >=0 && ttype <=1 || ttyped==1){
        realContent.destroy();
        scrbox.add(realContent);
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
        if (history.length ==1){
          indicatorIcon.set_from_icon_name("clipboard-text-outline-symbolic", Gtk.IconSize.MENU);
        }
        for (int j = 0; j < history.length; j++) {
          if(j%maxPageitems == 0){
            pageNav+=1;
            listbax.append_val(new Gtk.ListBox());
          }
          add_loop(j);
        }
        } else {
          listbax.append_val(new Gtk.ListBox());
          Label clipMgrLabel = new Label(text);
          Button clipMgrButton = new Button();
          clipMgrButton.add(clipMgrLabel);
          clipMgrButton.set_sensitive (false);
          listbax.index(0).add(clipMgrButton);
        }
        nav_visible();
        for(int i = 0; i<listbax.length; i++){
          realContent.add(listbax.index(i));
        }
        update_pager();
        Applet.popover.get_child().show_all();
        hide_all_listbax_but_show(currPage - 1);
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
        Label clipMgrLabel = new Label(text);
        Button clipMgrButton = new Button();
        clipMgrButton.add(clipMgrLabel);
        clipMgrButton.set_sensitive (false);
        realContent.add(clipMgrButton);
        nav_visible();
        update_pager();
        Applet.popover.get_child().show_all();
      }
    }
    public static void add_loop(int j){
      text = history.index(j);
      text = text.replace("\n", " ").strip();
      if (text.length >30){
        text = text.substring(0,30) + "...";
      }
      int copy = j;
      Box btnlist = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
      Box thislist = btnlist;
      Button clipMgr = new Button();
      Label clipMgrLabel = new Label(text);
      if (specialMark ==j){
      	text = Markup.escape_text(text);
        clipMgrLabel.set_label(@"<i><b><u>$text</u></b></i>");
        clipMgrLabel.use_markup = true;
      }
      clipMgrLabel.set_xalign(0);
      clipMgr.add(clipMgrLabel);
      clipMgr.set_hexpand(true);
      // print(@"$j =>  $(history.index (j)) \n");
      clipMgr.clicked.connect(()=>__on_row_activated(copy));
      btnlist.add(clipMgr);
      if (edMode){
        Button dismissbtn = new Button();
        Label dissLabel = new Label("X");
        dismissbtn.add(dissLabel);
          dismissbtn.clicked.connect(()=>{
            thislist.destroy();
            history.remove_index (copy);
            update_pager();
            nav_visible();
            Applet.popover.get_child().show_all();
          });
        btnlist.add(dismissbtn);
      }
    listbax.index(pageNav-1).add(btnlist);
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
      pagerCont.add(pager);
      pagerCont.set_sensitive (false);
    }
    public static void nav_visible(){
      if(pageNav>1 && history.length >maxPageitems){
        navbox.destroy();
        navbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        navContainer.add(navbox);
        Label prvNavLabel = new Gtk.Label("⟵");
        Button prvBtn = new Button();
        prvNavLabel.set_halign (Gtk.Align.CENTER);
        prvNavLabel.set_hexpand (true);
        Label pageNo = new Gtk.Label(@"$currPage/$pageNav");
        pageNo.set_halign (Gtk.Align.CENTER);
        pageNo.set_hexpand (true);
        Label nxtNavLabel = new Gtk.Label("⟶");
        Button nxtBtn = new Button();
        prvBtn.clicked.connect(()=>{
          if (currPage >1){
          currPage-=1;
          pageNo.set_label(@"$currPage/$pageNav");
          Applet.popover.get_child().show_all();
          hide_all_listbax_but_show(currPage - 1);
        }});
        nxtBtn.clicked.connect(()=>{
          if (currPage < listbax.length){
          currPage+=1;
          pageNo.set_label(@"$currPage/$pageNav");
          Applet.popover.get_child().show_all();
          hide_all_listbax_but_show(currPage - 1);
        }});
        nxtNavLabel.set_halign (Gtk.Align.CENTER);
        nxtNavLabel.set_hexpand (true);

        prvBtn.add(prvNavLabel);
        nxtBtn.add(nxtNavLabel);

        navbox.add(prvBtn);
        navbox.add(pageNo);
        navbox.add(nxtBtn);
      } else{
        navbox.destroy();
      }
    }
    public static void hide_all_listbax_but_show(int thiss = currPage - 1){
      //run after applet.popover.show all
      for(int i = 0; i<listbax.length; i++){
        listbax.index(i).hide();
      }
      listbax.index(thiss).show();
    }
    public static void on_search_activate (Gtk.Entry entry) {
      pageNav = 0;
      currPage =1;
      listbax = new Array<Gtk.ListBox>();
      listbax.append_val(new Gtk.ListBox());
      Button goBackBtn = new Gtk.Button.with_label("<-  Go Back    ");
      goBackBtn.clicked.connect(()=>{
        addRow(0);
        entry.set_text("");
      });
      string gotText = entry.get_text();
      realContent.destroy();
      scrbox.add(realContent);
      int j=0;
      for (int i=0;i<history.length;i++){
        if (history.index(i).contains(gotText)){
          if(j%maxPageitems == 0){
            pageNav+=1;
            listbax.append_val(new Gtk.ListBox());
          }
          add_loop(i);
          j++;
        }
      }
      if (j==0){
        listbax.index(0).add(new Label("No Results found!"));
      }
      nav_visible();
      for(int i = 0; i<listbax.length; i++){
        realContent.add(listbax.index(i));
      }
      if (minimalinterface){
        realContent.add(goBackBtn);
      } else {
        realContent.prepend(goBackBtn);
      }
      update_pager();
      Applet.popover.get_child().show_all();
      hide_all_listbax_but_show(currPage - 1);
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
    public static GLib.Settings settings = new GLib.Settings("com.prateekmedia.clipboardmanager");
    public string uuid { public set; public get; }
    /* specifically to the settings section */
    public override bool supports_settings() {
      return true;
    }
    public override Gtk.Widget ? get_settings_ui() {
      return new ClipboardManagerSettings(settings);
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
