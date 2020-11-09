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

namespace SupportingFunctions {
/*
 * Here we keep the (possibly) shared stuff, or general functions, to
 * keep the main code clean and readable
 */
}


namespace ClipboardManagerApplet {

public class ClipboardManagerSettings : Gtk.Grid {
/* Budgie Settings -section */
GLib.Settings? settings = null;

public ClipboardManagerSettings(GLib.Settings? settings) {
	/*
	 * Gtk stuff, widgets etc. here
	 */
}
}


public class Plugin : Budgie.Plugin, Peas.ExtensionBase {
public Budgie.Applet get_panel_widget(string uuid) {
	return new Applet();
}
}


public class ClipboardManagerPopover : Budgie.Popover {
private EventBox indicatorBox;
private Image indicatorIcon;
public Clipboard clipboard;
public ListBox mainContent = new ListBox();
/* process stuff */
/* GUI stuff */
/* misc stuff */

public ClipboardManagerPopover(Gtk.EventBox indicatorBox) {
	Object(relative_to: indicatorBox);

	this.indicatorBox = indicatorBox;

	indicatorIcon = new Gtk.Image.from_icon_name(
		"clipboard-text-outline-symbolic", Gtk.IconSize.MENU
		);
	indicatorBox.add(this.indicatorIcon);

	/* gsettings stuff */

	/* box */
	add(mainContent);
	Timeout.add_seconds_full(Priority.LOW, 1, update_clipboard);
}

public bool update_clipboard(){
	string text = "";
	clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD);
	clipboard.owner_change.connect ((ev) => {
				text = clipboard.wait_for_text();
				text = text.substring (0, 30);
				Button clipMgr = new Button();
				Label clipMgrLabel = new Label(null);
				if (text[0] == '\0' || text == null) {
				        clipMgrLabel.set_text(_("Clipboard Current Empty, Copy Something to see the magic!"));
				} else{
				        clipMgrLabel.set_text(_(text));
				        clipMgrLabel.set_max_width_chars(30);
				}
				clipMgr.add(clipMgrLabel);
				mainContent.add(clipMgr);
			});
	return true;
}

}


public class Applet : Budgie.Applet {
private Gtk.EventBox indicatorBox;
private ClipboardManagerPopover popover = null;
private unowned Budgie.PopoverManager? manager = null;
public Clipboard clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD);
public ListBox mainContent = new ListBox();
int HISTORY_LENGTH = 10;
string?[] history;
string?[] rows;
bool row_activated_flag = false;
public string uuid {
	public set; public get;
}
/* specifically to the settings section */
public override bool supports_settings()
{
	return true;
}
public override Gtk.Widget ? get_settings_ui()
{
	return new ClipboardManagerSettings(this.get_applet_settings(uuid));
}

public Applet() {
	/* box */
	indicatorBox = new Gtk.EventBox();
	add(indicatorBox);
	/* Popover */
	popover = new ClipboardManagerPopover(indicatorBox);
	/* On Press indicatorBox */
	indicatorBox.button_press_event.connect((e)=> {
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
	popover.get_child().show_all();
	show_all();
}
// protected bool insert_row() {
// }
// protected bool update_ui() {
// }
public override void update_popovers(Budgie.PopoverManager? manager)
{
	this.manager = manager;
	manager.register_popover(indicatorBox, popover);
}
}
}



[ModuleInit]
public void peas_register_types(TypeModule module){
	/* boilerplate - all modules need this */
	var objmodule = module as Peas.ObjectModule;
	objmodule.register_extension_type(typeof(Budgie.Plugin), typeof(ClipboardManagerApplet.Plugin));
}
