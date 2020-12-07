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
        if (text != null && text.chug().length != 0){
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
        if (select_clip && text != null && text.chug().length != 0 ){
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

        

        //Case Sensitive Search
        Label caseSenLabel = new Gtk.Label("Case Sensitive Search");
        caseSenLabel.set_halign (Gtk.Align.START);
        caseSenLabel.set_hexpand (true);
        Switch caseSenTggle = new Gtk.Switch();
        caseSenTggle.set_active(settings.get_boolean("searchsensitive"));
        caseSenTggle.set_halign (Gtk.Align.END);
        caseSenTggle.set_hexpand (true);
        
        
        //Save History to Schemas
        Label saveHistLabel = new Gtk.Label("Save History to Schemas");
        saveHistLabel.set_halign (Gtk.Align.START);
        saveHistLabel.set_hexpand (true);
        Switch saveHistTggle = new Gtk.Switch();
        saveHistTggle.set_active(settings.get_boolean("savehistory"));
        saveHistTggle.set_halign (Gtk.Align.END);
        saveHistTggle.set_hexpand (true);
        
        
        //Clipboard height Label
        Label heightLabel = new Gtk.Label("Clipboard Height");
        heightLabel.set_halign (Gtk.Align.START);
        heightLabel.set_hexpand (true);
        SpinButton heightSpin = new Gtk.SpinButton.with_range (50, 2000, 1);
        heightSpin.set_value(settings.get_int("clipheight"));
        heightSpin.set_halign (Gtk.Align.END);
        heightSpin.set_hexpand (true);
        
        //Reset Btn Label
        var resetBtn = new Gtk.Button.with_label("Restore Defaults");
        resetBtn.set_halign (Gtk.Align.START);
        resetBtn.set_hexpand (true);
        
        attach (historyLabel,	0, 0, 1, 1);
        attach (historySpin,	1, 0, 1, 1);
        attach (selClipLabel,	0, 1, 1, 1);
        attach (selClipTggle,	1, 1, 1, 1);
        attach (copySelLabel,	0, 2, 1, 1);
        attach (copySelTggle,	1, 2, 1, 1);
        attach (caseSenLabel,	0, 3, 1, 1);
        attach (caseSenTggle,	1, 3, 1, 1);
        attach (saveHistLabel,	0, 4, 1, 1);
        attach (saveHistTggle,	1, 4, 1, 1);
        attach (heightLabel,	0, 5, 1, 1);
        attach (heightSpin,		1, 5, 1, 1);
        attach (resetBtn,		0, 6, 1, 1);

        historySpin.value_changed.connect (()=>{
          int curr_val = historySpin.get_value_as_int();
          if(ClipboardManagerPopover.HISTORY_LENGTH != curr_val){
            settings.set_int("historylength" , curr_val);
            ClipboardManagerPopover.HISTORY_LENGTH = curr_val;
            ClipboardManagerPopover.show_all_except();
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
        
        caseSenTggle.state_set.connect (()=>{
          bool curr_act = caseSenTggle.get_active();
          settings.set_boolean("searchsensitive" , curr_act);
          ClipboardManagerPopover.searchsensitive = curr_act;
          return false;
        });
        
        saveHistTggle.state_set.connect (()=>{
          bool curr_act = saveHistTggle.get_active();
          settings.set_boolean("savehistory" , curr_act);
          Applet.savehistory = curr_act;
          return false;
        });
         
        heightSpin.value_changed.connect (()=>{
          int curr_val = heightSpin.get_value_as_int();
          if(ClipboardManagerPopover.clipheight != curr_val){
            settings.set_int("clipheight", curr_val);
			ClipboardManagerPopover.realContent.set_min_content_height (curr_val);
            ClipboardManagerPopover.show_all_except();
          }
        });
        
        resetBtn.clicked.connect(()=>{
        	settings.reset("historylength");
        	settings.reset("selectclip");
        	settings.reset("copyselected");
        	settings.reset("searchsensitive");
        	settings.reset("savehistory");
        	settings.reset("clipheight");
        	
        	settings.reset("editmode");
        	settings.reset("privatemode");
        	
        	historySpin.set_value(settings.get_int("historylength"));
		heightSpin.set_value(settings.get_int("clipheight"));
		selClipTggle.set_active(settings.get_boolean("selectclip"));
		copySelTggle.set_active(settings.get_boolean("copyselected"));
        	caseSenTggle.set_active(settings.get_boolean("searchsensitive"));
        	saveHistTggle.set_active(settings.get_boolean("savehistory"));
		copySelTggle.set_sensitive (false);
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
	public static ListBox scrbox = new ListBox();
	public static ScrolledWindow realContent = new Gtk.ScrolledWindow (null,null);
	public static Separator spacerCont = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
	public static Box editMode = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
	public static Box privateMode = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
	public static bool edMode = settings.get_boolean("editmode");
	public static bool primode = settings.get_boolean("privatemode");
	public static ListBox setContent = new ListBox();
	public static Box hBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
	public static Box settingsBox = new Box(Gtk.Orientation.VERTICAL, 0);
	public static Button pagerCont = new Gtk.Button ();
	public static Button setDropdown = new Gtk.Button ();
	public static bool dropCount = false;
	public static string text;
	public static int clipheight =  settings.get_int("clipheight");
	public static bool copyselected =  settings.get_boolean("copyselected");
	public static bool searchsensitive =  settings.get_boolean("searchsensitive");
	public static int HISTORY_LENGTH = settings.get_int("historylength");
	public static Array<string> history = new Array<string> ();
	public static ListBox listbax = new Gtk.ListBox ();
	public static bool row_activated_flag = false;
	public static bool private_mode = false;
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

		/* box */
		add(mainContent);
		realContent.set_overlay_scrolling(true);
		realContent.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		realContent.set_min_content_height (clipheight);
		scrbox.add(realContent);
		mainContent.add(search_container);
		mainContent.add(scrbox);
		mainContent.add(spacerCont);
		mainContent.add(setContent);   

		hBox.add(pagerCont);
		hBox.add(setDropdown);
		
		setDropdown.set_label("▼");
		setDropdown.clicked.connect(()=>{
			dropCount =  !dropCount;
			show_all_except();
		});
        pagerCont.set_hexpand (true);

		setContent.add(hBox);
		setContent.add(settingsBox);

		string emptyCliptext = "Empty Clipboard ";
		Button emptyClip = new Button();
		emptyClip.clicked.connect(remove_all_rows);
		Label emptyClipLabel = new Label(@"<b>$emptyCliptext</b>");
		emptyClipLabel.set_xalign(0);
		emptyClipLabel.use_markup = true;
		emptyClip.add(emptyClipLabel);
		settingsBox.add(emptyClip);

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

		settingsBox.add(editMode);

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
		settingsBox.add(privateMode);

		search_box.set_placeholder_text("Search Clipboard....");
		search_box.set_hexpand(true);
		search_box.changed.connect(()=>{
			text = search_box.get_text();
			if (text.chug().length != 0 && history.length !=0){
			 	on_search_activate(search_box);
			}
			else{
			 	addRow(0);
			}
		});
		search_container.add(search_box);
    }

	public static void addRow(int ttype){
	  if (!row_activated_flag){
		text = ClipboardManager.get_clipboard_text();
	  }
	  realContent.remove(listbax);
	  listbax = new Gtk.ListBox ();
	  if (ttype==0) { text = ClipboardManager.get_clipboard_text(); } 
	  else if (ttype ==1 ) { text = ClipboardManager.get_selected_text(); } 
	  else if (ttype ==2) { 
		if (history.length == 0 || text == null || text.chug().length ==0){
		    text = "Clipboard is Currently Empty!";
		    ttyped = 0;
		} else {
		    ttyped = 1;
		}
	   } 
	  else { text = ""; }
	  if (ttype >=0 && ttype <=1 || ttyped==1){
		  for (int j = 0; j < history.length; j++){
		    if(text == history.index(j)){
		      history.remove_index(j);
		      break;
		    }
		  }
		  update_history(text);
		  specialMark = 0;
		if (copyselected && ttype ==1){
		  ClipboardManager.set_text(text);
		}
		row_activated_flag = false;
		if (history.length >=1){
		  indicatorIcon.set_from_icon_name("clipboard-text-outline-symbolic", Gtk.IconSize.MENU);
		}
		for (int j = 0; j < history.length; j++) {
		  add_loop(j);
		}
		} else {
		  Label clipMgrLabel = new Label(text);
		  Button clipMgrButton = new Button();
		  clipMgrButton.add(clipMgrLabel);
		  clipMgrButton.set_sensitive (false);
		  listbax.add(clipMgrButton);
		}
		realContent.add(listbax);
		update_pager();
		show_all_except();
	}

	public static void remove_all_rows(){
		if (history.length >0){
			realContent.remove(listbax);
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
			update_pager();
			show_all_except();
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
			history.remove_index (copy);
			row_activated_flag = true;
			addRow(2);
		  });
		btnlist.add(dismissbtn);
		}
		listbax.add(btnlist);
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
		if (Applet.savehistory){
			string[] histring = {};
			for (int i = 0; i < history.length ; i++) {
				histring += history.index (i);
			}
			settings.set_strv("history", histring);
		}
	}
	
	public static void show_all_except(){
		Applet.popover.get_child().show_all();
		if (dropCount) {
			settingsBox.show();
			setDropdown.set_label("▲");
		}
		else { 
			settingsBox.hide();
			setDropdown.set_label("▼");
		}
	}

	public static void update_pager(){
		pagerCont.set_label(@"$(history.length)/$HISTORY_LENGTH");
        pagerCont.set_hexpand (true);
		pagerCont.set_sensitive (false);
	}

	public static void on_search_activate (Gtk.Entry entry) {
		realContent.remove(listbax);
		listbax = new Gtk.ListBox();
		string gotText = entry.get_text();
		int j=0;
		for (int i=0;i<history.length;i++){
			if (history.index(i).contains(gotText)){
				add_loop(i);
				j++;
			} else if(!searchsensitive && history.index(i).down().contains(gotText.down())){
				add_loop(i);
				j++;
			}
		}
		if (j==0){ listbax.add(new Label("No Results found!")); }
		realContent.add(listbax);
		update_pager();
		show_all_except();
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
		public override bool supports_settings() { return true; }
		public override Gtk.Widget ? get_settings_ui() { return new ClipboardManagerSettings(settings); }
		public static string[] historv =  settings.get_strv("history");
		public static bool savehistory = settings.get_boolean("savehistory");

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
			if (savehistory){
				for (int i = 0; i < historv.length ; i++) {
					ClipboardManagerPopover.history.append_val(historv[i]);
				}
			}
			ClipboardManagerPopover.addRow(2);
			ClipboardManager.attach_monitor_clipboard();
			popover.get_child().show_all();
			show_all();
			ClipboardManagerPopover.show_all_except();
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

