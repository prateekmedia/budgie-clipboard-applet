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
    private static Gtk.Clipboard monitor_clipboard;
    private static Gtk.Clipboard monitor_clipboard_selection;
	
    public static bool attach_monitor_clipboard() {
        monitor_clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);
        monitor_clipboard_selection = Gtk.Clipboard.get (Gdk.SELECTION_PRIMARY);
        bool select_clip = ClipboardManagerApplet.Applet.settings.get_boolean("selectclip");
        if(!ClipboardManagerApplet.ClipboardManagerPopover.primode){
            monitor_clipboard.owner_change.connect (for_clipboard_text);
            if(select_clip){
                monitor_clipboard_selection.owner_change.connect (for_selected_text);
            } else {
                monitor_clipboard_selection.owner_change.disconnect (for_selected_text);
            }
        } else {
            monitor_clipboard.owner_change.disconnect (for_clipboard_text);
            monitor_clipboard_selection.owner_change.disconnect (for_selected_text);
        }
        return false;
    }

    public static string get_text (bool selectedOne = false) {
        var clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);
        if (selectedOne){
                 clipboard = Gtk.Clipboard.get (Gdk.SELECTION_PRIMARY);
        }
        return clipboard.wait_for_text ();
    }	

    public static void set_text (string? item) {
        var clipboard = Gtk.Clipboard.get (Gdk.SELECTION_CLIPBOARD);
        if (item != null &&item != clipboard.wait_for_text ()){
                clipboard.set_text (item, item.length);
        }
        if (ClipboardManagerApplet.ClipboardManagerPopover.pasteFromClipboard){
            try {
                Process.spawn_command_line_async("xdotool key shift+Insert");
            }
            catch (Error e) {
                warning ("Error: xdotool not installed");
            }
        }
    }

    public static void for_clipboard_text(){do_this_with_text();}
    
    public static void for_selected_text(){do_this_with_text(true);}

    public static void do_this_with_text (bool selectedOne = false) {
        string[] history = ClipboardManagerApplet.ClipboardManagerPopover.history;
        string text = get_text(selectedOne);
        var num = 0;
        if (text != null && text.chug().length != 0){
            if(selectedOne && text.contains(history[0])){
                ClipboardManagerApplet.ClipboardManagerPopover.remove_index_from_history(0);
            }
            if (selectedOne){
                num = 1;}
            if( text !=history[0]){
                ClipboardManagerApplet.ClipboardManagerPopover.addRow(num);
            }
        }
    }

    public static string[] readfile (string path) {
        try {
            string read;
            FileUtils.get_contents (path, out read);
            var data = read.split (" : ");
            string[] newdata = {};
            for (int i=0; i<data.length; i++){
                newdata += data[i].replace(":;", ":");
            }
            return newdata;
        } catch (FileError error) {
            string[] welcome = {_("Welcome to Clipboard Manager"), _("Your Clips will be saved Automatically")};
            return welcome;
        }
    }

    public static void writefile (string path, string[] clips) {
        try {
            string[] newclips = {};
            for (int i=0; i<clips.length; i++){
                newclips += clips[i].replace(":", ":;");
            }
            string clipdata = string.joinv(" : ",newclips);
            FileUtils.set_contents (path, clipdata);
        } catch (FileError error) {
            warning ("Cannot write to file. Is the directory available?");
        }
    }
    
    public static string get_filepath(GLib.Settings settings, string key) {
        string filename = "clipmgr_data.txt";
        string filepath = settings.get_string(key);
        if (filepath == "") {
            string homedir = Environment.get_home_dir();
            string settingsdir = ".config/prateekmedia/clipboardmanger";
            string custompath = GLib.Path.build_path("/", homedir, settingsdir);
            File file = File.new_for_path(custompath);
            try {
                file.make_directory_with_parents();
            }
            catch (Error e) {
                /* the directory exists, nothing to be done */
            }
            return GLib.Path.build_filename(custompath, filename);
        }
        else {
            return GLib.Path.build_filename(filepath, filename);
        }
    }

    public static string[] get_clipstext (GLib.Settings settings, string key) {
        /* on startup of the applet, fetch the text */
        string filepath = get_filepath(settings, key);
        string[] initialclips = readfile(filepath);
        return initialclips;
    }
  
    public static void send_notification_now(string title, string body, string icon= "clipboard-text-outline-symbolic"){
        GLib.Application application = new GLib.Application ("com.prateekmedia.clipboardmanager", GLib.ApplicationFlags.FLAGS_NONE);
	    try {	
	        application.register ();
	    } catch (Error e) {
            warning ("Error: %s", e.message);
        }
        var notification = new Notification(title);
        notification.set_body(body);
	    notification.set_priority(NotificationPriority.NORMAL);	
        application.send_notification("com.prateekmedia.clipboardmanager", notification);
    }
}

namespace ClipboardManagerApplet {
  private static Gtk.Clipboard monitor_clipboard_selection;
  public class ClipboardManagerSettings: Gtk.Grid {
    public ClipboardManagerSettings(GLib.Settings? settings) {
        // Gtk stuff, widgets etc. here
        set_row_spacing(10);
        monitor_clipboard_selection = Gtk.Clipboard.get (Gdk.SELECTION_PRIMARY);
        
        //History Label
        Label historyLabel = new Gtk.Label(_("History Size"));
        historyLabel.set_halign (Gtk.Align.START);
        historyLabel.set_hexpand (true);
        SpinButton historySpin = new Gtk.SpinButton.with_range (2, 100, 1);
        historySpin.set_value(settings.get_int("historylength"));
        historySpin.set_halign (Gtk.Align.END);
        historySpin.set_hexpand (true);

        //Get Selection on Clipboard
        Label selClipLabel = new Gtk.Label(_("Get Selection to Clipboard"));
        selClipLabel.set_halign (Gtk.Align.START);
        selClipLabel.set_hexpand (true);
        Switch selClipTggle = new Gtk.Switch();
        selClipTggle.set_active(settings.get_boolean("selectclip"));
        selClipTggle.set_halign (Gtk.Align.END);
        selClipTggle.set_hexpand (true);

        //Copy selection to Clipboard
        Label copySelLabel = new Gtk.Label(_("Copy Selection to Clipboard"));
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
        Label caseSenLabel = new Gtk.Label(_("Case Sensitive Search"));
        caseSenLabel.set_halign (Gtk.Align.START);
        caseSenLabel.set_hexpand (true);
        Switch caseSenTggle = new Gtk.Switch();
        caseSenTggle.set_active(settings.get_boolean("searchsensitive"));
        caseSenTggle.set_halign (Gtk.Align.END);
        caseSenTggle.set_hexpand (true);
        
        //Save History to Schemas
        Label saveHistLabel = new Gtk.Label(_("Save History to File"));
        saveHistLabel.set_halign (Gtk.Align.START);
        saveHistLabel.set_hexpand (true);
        Switch saveHistTggle = new Gtk.Switch();
        saveHistTggle.set_active(settings.get_boolean("savehistory"));
        saveHistTggle.set_halign (Gtk.Align.END);
        saveHistTggle.set_hexpand (true);
        
        //Save History to Schemas
        Label pastClipsLabel = new Gtk.Label(_("Paste after Clicking (Requires xdotool)"));
        pastClipsLabel.set_halign (Gtk.Align.START);
        pastClipsLabel.set_hexpand (true);
        Switch pastClipsTggle = new Gtk.Switch();
        pastClipsTggle.set_active(settings.get_boolean("pastefromclipboard"));
        pastClipsTggle.set_halign (Gtk.Align.END);
        pastClipsTggle.set_hexpand (true);
        
        //Clipboard height Label
        Label heightLabel = new Gtk.Label(_("Clipboard Height"));
        heightLabel.set_halign (Gtk.Align.START);
        heightLabel.set_hexpand (true);
        SpinButton heightSpin = new Gtk.SpinButton.with_range (50, 2000, 1);
        heightSpin.set_value(settings.get_int("clipheight"));
        heightSpin.set_halign (Gtk.Align.END);
        heightSpin.set_hexpand (true);
        
        //Reset Btn Label
        var resetBtn = new Gtk.Button.with_label(_("Restore Defaults"));
        resetBtn.set_halign (Gtk.Align.CENTER);
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
        attach (pastClipsLabel,	0, 5, 1, 1);
        attach (pastClipsTggle,	1, 5, 1, 1);
        attach (heightLabel,	0, 6, 1, 1);
        attach (heightSpin,		1, 6, 1, 1);
        attach (resetBtn,		0, 7, 1, 1);

        historySpin.value_changed.connect ((curr)=>{
            int curr_val = curr.get_value_as_int();
            if(ClipboardManagerPopover.HISTORY_LENGTH != curr_val){
                settings.set_int("historylength" , curr_val);
                ClipboardManagerPopover.HISTORY_LENGTH = curr_val;
                ClipboardManagerPopover.show_all_except();
            }
        });

        selClipTggle.state_set.connect ((curr_act)=>{
            settings.set_boolean("selectclip" , curr_act);
            copySelTggle.set_sensitive (curr_act);
            ClipboardManager.attach_monitor_clipboard();
            return false;
        });

        copySelTggle.state_set.connect ((curr_act)=>{
            settings.set_boolean("copyselected" , curr_act);
            ClipboardManagerPopover.copyselected = curr_act;
            return false;
        });
        
        caseSenTggle.state_set.connect ((curr_act)=>{
            settings.set_boolean("searchsensitive" , curr_act);
            ClipboardManagerPopover.searchsensitive = curr_act;
            return false;
        });
        
        saveHistTggle.state_set.connect ((curr_act)=>{
            settings.set_boolean("savehistory" , curr_act);
            ClipboardManagerPopover.savehistory = curr_act;
            return false;
        });
        
        pastClipsTggle.state_set.connect ((curr_act)=>{
            settings.set_boolean("pastefromclipboard" , curr_act);
            ClipboardManagerPopover.pasteFromClipboard = curr_act;
            return false;
        });
         
        heightSpin.value_changed.connect ((curr)=>{
            int curr_val = curr.get_value_as_int();
            settings.set_int("clipheight", curr_val);
            ClipboardManagerPopover.realContent.set_min_content_height (curr_val);
            ClipboardManagerPopover.show_all_except();
        });
        
        resetBtn.clicked.connect(()=>{
            string[] toBeReset = {"historylength", "selectclip", "copyselected", "searchsensitive", "savehistory", "pastefromclipboard", "clipheight", "privatemode"} ;
        	for (int i=0; i<toBeReset.length; i++){
        	    settings.reset(toBeReset[i]);
        	}
        	
        	historySpin.set_value(settings.get_int("historylength"));
		    selClipTggle.set_active(settings.get_boolean("selectclip"));
		    copySelTggle.set_active(settings.get_boolean("copyselected"));
		    copySelTggle.set_sensitive (false);
        	caseSenTggle.set_active(settings.get_boolean("searchsensitive"));
        	saveHistTggle.set_active(settings.get_boolean("savehistory"));
        	pastClipsTggle.set_active(settings.get_boolean("pastefromclipboard"));
		    heightSpin.set_value(settings.get_int("clipheight"));
		    ClipboardManagerPopover.privateModeTggle.set_active(settings.get_boolean("privatemode"));
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
	public static Box mainContent = new Box(Gtk.Orientation.VERTICAL, 4);
	public static Box search_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
	public static Entry search_box = new Gtk.Entry ();
	public static ListBox scrbox = new ListBox();
	public static ScrolledWindow realContent = new Gtk.ScrolledWindow (null,null);
	public static Box privateMode = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
	public static bool primode = settings.get_boolean("privatemode");
	public static Box notifyMe = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
	public static bool sendNotifications = settings.get_boolean("notifications");
	public static ListBox setContent = new ListBox();
	public static Box hBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
	public static Box settingsBox = new Box(Gtk.Orientation.VERTICAL, 8);
	public static Button pagerCont = new Gtk.Button ();
	public static Button setDropdown = new Gtk.Button ();
	public static bool dropCount = false;
    public static Image goUp = new Gtk.Image.from_icon_name("pan-up-symbolic", Gtk.IconSize.BUTTON);
    public static Image goDown = new Gtk.Image.from_icon_name("pan-down-symbolic", Gtk.IconSize.BUTTON);
	public static string text;
	public static int clipheight =  settings.get_int("clipheight");
	public static bool copyselected =  settings.get_boolean("copyselected");
	public static bool searchsensitive =  settings.get_boolean("searchsensitive");
	public static int HISTORY_LENGTH = settings.get_int("historylength");
	public static string[] history = {};
	public static bool savehistory = settings.get_boolean("savehistory");
	public static bool pasteFromClipboard = settings.get_boolean("pastefromclipboard");
	public static ListBox listbax = new Gtk.ListBox ();
	public static bool row_activated_flag = false;
	public static Switch privateModeTggle = new Gtk.Switch();
	public static int ttyped = 0;
	public static int specialMark = 0;
	/* process stuff */
	/* GUI stuff */
    /* misc stuff */

	public ClipboardManagerPopover(Gtk.EventBox indicatorBox) {
		Object(relative_to: indicatorBox);
        
		indicatorIcon = new Gtk.Image.from_icon_name("clipboard-outline-symbolic", Gtk.IconSize.MENU);
        if (primode){
	        indicatorIcon.set_from_icon_name("clipboard-outline-broken-symbolic", Gtk.IconSize.MENU);
        }
		indicatorBox.add(indicatorIcon);
		
		//Get History
		if (savehistory){
            history = ClipboardManager.get_clipstext(settings, "custompath");
            remove_index_from_history(-1);
		}

		/* box */
		add(mainContent);
		realContent.set_overlay_scrolling(true);
		realContent.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.EXTERNAL);
		realContent.set_min_content_height (clipheight);
		scrbox.add(realContent);
		mainContent.add(search_container);
		mainContent.add(scrbox);
		mainContent.add(setContent);   

		hBox.add(pagerCont);
		hBox.add(setDropdown);
		
		setDropdown.set_image(goDown);
		setDropdown.clicked.connect(()=>{
			dropCount =  !dropCount;
			show_all_except();
		});
        pagerCont.set_hexpand (true);

		setContent.add(hBox);
		setContent.add(settingsBox);
		
		update_pager();

		string emptyCliptext = _("Clear All");
		Button emptyClip = new Button();
		emptyClip.clicked.connect(remove_all_rows);
		Label emptyClipLabel = new Label(@"<b>$emptyCliptext</b>");
		emptyClipLabel.set_xalign(0);
		emptyClipLabel.use_markup = true;
		emptyClip.add(emptyClipLabel);
		settingsBox.add(emptyClip);

		Label privateModeLabel = new Gtk.Label("   " + _("Private Mode"));
		privateModeLabel.set_halign (Gtk.Align.START);
		privateModeLabel.set_hexpand (true);
		privateModeTggle.set_active(primode);
		privateModeTggle.set_halign (Gtk.Align.END);
		privateModeTggle.set_hexpand (true);

		privateModeTggle.state_set.connect (()=>{
            bool curr_act = privateModeTggle.get_active();
            settings.set_boolean("privatemode" , curr_act);
            primode = curr_act;
            ClipboardManager.attach_monitor_clipboard();
            if (curr_act){
		        indicatorIcon.set_from_icon_name("clipboard-outline-broken-symbolic", Gtk.IconSize.MENU);
            } else {
                if (history.length !=0){ indicatorIcon.set_from_icon_name("clipboard-text-outline-symbolic", Gtk.IconSize.MENU);
                } else { indicatorIcon.set_from_icon_name("clipboard-outline-symbolic", Gtk.IconSize.MENU); }
            }
            return false;
		});

		privateMode.set_tooltip_text(_("Enabling this will stop Clipboard Manager to save any Clips"));
		privateMode.add(privateModeLabel);
		privateMode.add(privateModeTggle);
		settingsBox.add(privateMode);
		
		
		Label notifyMeLabel = new Gtk.Label("   " + _("Notifications"));
		notifyMeLabel.set_halign (Gtk.Align.START);
		notifyMeLabel.set_hexpand (true);
		Switch notifyMeTggle = new Gtk.Switch();
		notifyMeTggle.set_active(sendNotifications);
		notifyMeTggle.set_halign (Gtk.Align.END);
		notifyMeTggle.set_hexpand (true);

		notifyMeTggle.state_set.connect (()=>{
            bool curr_act = notifyMeTggle.get_active();
            settings.set_boolean("notifications" , curr_act);
            sendNotifications = curr_act;
            return false;
		});

		notifyMe.set_tooltip_text(_("Enabling this will Notify you about every clips you copy"));
		notifyMe.add(notifyMeLabel);
		notifyMe.add(notifyMeTggle);
		settingsBox.add(notifyMe);

		search_box.set_placeholder_text(_("Search Clipboard History")+"…");
		search_box.set_hexpand(true);
		search_box.changed.connect(()=>{
			text = search_box.get_text();
			if (text.chug().length != 0 && history.length !=0){
			 	on_search_activate(search_box);
			}
			else{
		        remove_and_create_listbax();
                add_marked_text_in_loop();
		        realContent.add(listbax);
		        update_pager();
		        show_all_except();
			}
		});
		search_container.add(search_box);
    }

	public static void addRow(int ttype){
	  if (!row_activated_flag){
		text = ClipboardManager.get_text();
	  }
	  remove_and_create_listbax();
	  if (ttype==0) { text = ClipboardManager.get_text(); } 
	  else if (ttype ==1 ) { text = ClipboardManager.get_text(true); } 
	  else if (ttype ==2) { 
		if (history.length == 0 && (text == null || text.chug().length ==0)){
		    ttyped = 0;
		} else {
		    ttyped = 1;
		}
	   } 
	  else { text = ""; }
        if (ttype!=2 || ttyped==1){
            if (copyselected && ttype == 1){
              ClipboardManager.set_text(text);
            }
            add_marked_text_in_loop(0, text);
        } else {
            clip_curr_empty();
        }
		realContent.add(listbax);
		update_pager();
		show_all_except();
	}

	public static void remove_all_rows(){
		if (history.length >0){
		    remove_and_create_listbax();
			remove_range_from_history(0);
			indicatorIcon.set_from_icon_name("clipboard-outline-symbolic", Gtk.IconSize.MENU);
			Applet.popover.hide();
			ClipboardManager.set_text("");
		    clip_curr_empty();
			realContent.add(listbax);
			update_pager();
			show_all_except();
		}
	}
	
	public static void add_marked_text_in_loop(int copy = 0, string? text =null){
	    if(text!=null){
	        delete_duplicates_from_history(text);
	    }
	    if (history.length>0){
            specialMark = copy;
            row_activated_flag = false;
            for (int j = 0; j < history.length; j++) {
              add_element_to_listbax(j);
            }
	    } else {
	        clip_curr_empty();
	    }
	    update_history();
    }
    
	public static void add_element_to_listbax(int j){
		text = history[j];
	    string subtext = text.replace("\t", " ").strip();;
		if (subtext.length >100){
		     subtext = text.strip().slice(0,100) + "...";  
		}
		text = text.replace("\n", " ").strip();
		if (text.length >30){
		text = text.slice(0,30) + "...";
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
		clipMgr.set_tooltip_text(subtext);
		// print(@"$j =>  $(history[j]) \n");
		clipMgr.clicked.connect(()=>__on_row_activated(copy));
		btnlist.add(clipMgr);
		Button dismissbtn = new Button();
		Image dissImage =  new Gtk.Image.from_icon_name("edit-delete-symbolic", Gtk.IconSize.BUTTON);;
		dismissbtn.set_image(dissImage);
		  dismissbtn.clicked.connect(()=>{
			remove_index_from_history(copy);
		    row_activated_flag = true;
		    remove_and_create_listbax();
		    add_marked_text_in_loop();
		    realContent.add(listbax);
		    update_pager();
		    show_all_except();
		  });
		btnlist.add(dismissbtn);
		listbax.add(btnlist);
	}
	
	public static void remove_and_create_listbax(){
        int z = 0;
        realContent.@foreach((widget)=>{
          z++;
        });
        if (z !=0){
            realContent.remove(listbax);
        }
        listbax = new Gtk.ListBox ();
	}

	public static void update_history(string? text = null){
	    string[] newHistory = {};
	    if (text!=null){
            newHistory += text;
        }
        for (int i=0; i<history.length; i++){
            newHistory += history[i];
        }
		history = newHistory;
		if (history.length >=1 && !primode){
	        indicatorIcon.set_from_icon_name("clipboard-text-outline-symbolic", Gtk.IconSize.MENU);
	    }
		if (history.length > HISTORY_LENGTH){
			if(history.length == HISTORY_LENGTH+1){
				remove_index_from_history(HISTORY_LENGTH);
			} else{
		  		remove_range_from_history(HISTORY_LENGTH-1);
			}
		}
		if (savehistory){
            ClipboardManager.writefile(ClipboardManager.get_filepath(settings, "custompath"), history);
		}
	}
	
	public static void remove_index_from_history(int idx){
	    string[] newArray = {};
        for (int i=0; i<history.length; i++){
            if (i!=idx && history[i].chug().length!=0){
                newArray += history[i];
        }}
		history = newArray;
	}
	
	public static void remove_range_from_history(int idx){
	    string[] newArray = {};
        for (int i=0; i<history.length; i++){
            if (i<idx){
                newArray += history[i];
        }}
		history = newArray;
	}
	
	public static void delete_duplicates_from_history(string text){
        for (int j = 0; j < history.length; j++){
            if(text == history[j]){
              remove_index_from_history(j);
              break;
            }
        }
        update_history(text);
	}
	
	public static void show_all_except(){
		Applet.popover.get_child().show_all();
		if (dropCount) {
			settingsBox.show();
			setDropdown.set_image(goUp);
		}
		else { 
			settingsBox.hide();
			setDropdown.set_image(goDown);
		}
	}

	public static void update_pager(){
		pagerCont.set_label(@"$(history.length)/$HISTORY_LENGTH");
        pagerCont.set_hexpand (true);
		pagerCont.set_sensitive (false);
	}

	public static void clip_curr_empty(string emptyText = "No Clipboard Items Found"){
	    string text = _(emptyText);
	    if (emptyText.contains("Found")){
	        indicatorIcon.set_from_icon_name("clipboard-outline-symbolic", Gtk.IconSize.MENU);
	    }
	    Label clipLabel = new Label(text);
	    Button clipButton = new Button();
	    clipButton.add(clipLabel);
	    clipButton.set_sensitive (false);
	    listbax.add(clipButton);
	}
	
	public static void on_search_activate (Gtk.Entry entry) {
	    remove_and_create_listbax();
		string gotText = entry.get_text();
		int j=0;
		for (int i=0;i<history.length;i++){
			if (history[i].contains(gotText)){
				add_element_to_listbax(i);
				j++;
			} else if(!searchsensitive && history[i].down().contains(gotText.down())){
				add_element_to_listbax(i);
				j++;
			}
		}
		if (j==0){ clip_curr_empty(_("Try changing search terms")+"."); }
		realContent.add(listbax);
		update_pager();
		show_all_except();
	}

	public static void __on_row_activated(int copy){
		Applet.popover.hide();
		row_activated_flag = true;
		string text = history[copy];
		ClipboardManager.set_text(text);
		if (primode){
		    remove_and_create_listbax();
            add_marked_text_in_loop(copy);
		    realContent.add(listbax);
		    update_pager();
		    show_all_except();
		}
		text = text.replace("\t", "  ");
		if (text.length > 250){
		    text = text.slice(0,250) + "...";
		}
		if (sendNotifications){
		    ClipboardManager.send_notification_now(_("Copied")+"!", text);
		}
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
