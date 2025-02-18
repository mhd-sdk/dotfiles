import { bind, GLib, Variable } from "astal";
import { Astal, Gtk } from "astal/gtk3";
import Tray from "gi://AstalTray";
import { Workspaces } from "./Workspaces";

function Time({ format = "%c" }) {
    const time = Variable("").poll(1000, () => GLib.DateTime.new_now_local().format(format)!);
    return <label className="Time" onDestroy={() => time.drop()} label={time()} />;
}

function SysTray() {
    const tray = Tray.get_default()

    return <box className="SysTray">
        {bind(tray, "items").as(items => items.map(item => (
            <menubutton
                tooltipMarkup={bind(item, "tooltipMarkup")}
                usePopover={false}
                actionGroup={bind(item, "actionGroup").as(ag => ["dbusmenu", ag])}
                menuModel={bind(item, "menuModel")}>
                <icon gicon={bind(item, "gicon")} />
            </menubutton>
        )))}
    </box>
}

export default function Bar(monitor: number) {
    const { BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor;
    return (
        <window namespace="status-bar" className="Bar" heightRequest={25} gdkmonitor={monitor} exclusivity={Astal.Exclusivity.EXCLUSIVE} anchor={BOTTOM | LEFT | RIGHT}>
            <centerbox>
                <box hexpand halign={Gtk.Align.START}>
                    <Workspaces />
                </box>
                <box hexpand halign={Gtk.Align.CENTER}>
                    
                </box>
                <box hexpand halign={Gtk.Align.END}>
                    <SysTray />
                    <Time />
                </box>
            </centerbox>
        </window>
    );
};


