using Gtk;

/*
* Template
* Author: Jacob Vlijm
* Copyright © 2017-2018 Ubuntu Budgie Developers
* Website=https://ubuntubudgie.org
* This program is free software: you can redistribute it and/or modify it
* under the terms of the GNU General Public License as published by the Free
* Software Foundation, either version 3 of the License, or any later version.
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
* more details. You should have received a copy of the GNU General Public
* License along with this program.  If not, see
* <https://www.gnu.org/licenses/>.
*/

namespace SupportingFunctions {
    /*
    * Here we keep the (possibly) shared stuff, or general functions, to
    * keep the main code clean and readable
    */
}


namespace TemplateApplet {

    public class TemplateSettings : Gtk.Grid {
        /* Budgie Settings -section */
        GLib.Settings? settings = null;

        public TemplateSettings(GLib.Settings? settings) {
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


    public class TemplatePopover : Budgie.Popover {
        private Gtk.EventBox indicatorBox;
        private Gtk.Image indicatorIcon;
        /* process stuff */
        /* GUI stuff */
        private Grid maingrid;
        /* misc stuff */

        public TemplatePopover(Gtk.EventBox indicatorBox) {
            GLib.Object(relative_to: indicatorBox);
            indicatorBox = indicatorBox;
            /* set icon */
            indicatorIcon = new Gtk.Image.from_icon_name(
                "clipboard-text-outline-symbolic", Gtk.IconSize.MENU
            );
            indicatorBox.add(this.indicatorIcon);

            /* gsettings stuff */

            /* grid */
            maingrid = new Gtk.Grid();
            maingrid.attach(new Label("  Clipboard is currrently Empty  "), 0, 0, 1, 1);

            this.add(this.maingrid);
        }
    }


    public class Applet : Budgie.Applet {

        private Gtk.EventBox indicatorBox;
        private TemplatePopover popover = null;
        private unowned Budgie.PopoverManager? manager = null;
        public string uuid { public set; public get; }
        /* specifically to the settings section */
        public override bool supports_settings()
        {
            return true;
        }
        public override Gtk.Widget? get_settings_ui()
        {
            return new TemplateSettings(this.get_applet_settings(uuid));
        }

        public Applet() {
            /* box */
            indicatorBox = new Gtk.EventBox();
            add(indicatorBox);
            /* Popover */
            popover = new TemplatePopover(indicatorBox);
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
    objmodule.register_extension_type(typeof(
        Budgie.Plugin), typeof(TemplateApplet.Plugin)
    );
}
