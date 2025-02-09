import { GLib, Variable } from "astal";
import { Astal, Gtk } from "astal/gtk3";
import { StatusIcons } from "./StatusIcons";

function Time({ format = "%c" }) {
    const time = Variable("").poll(1000, () => GLib.DateTime.new_now_local().format(format)!);
    return <label className="Time" onDestroy={() => time.drop()} label={time()} />;
}

export const Bar = (monitor: number) => {
    const { BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor;
    return (
        <window namespace="status-bar" className="Bar" heightRequest={20} gdkmonitor={monitor} exclusivity={Astal.Exclusivity.EXCLUSIVE} anchor={BOTTOM | LEFT | RIGHT}>
            <centerbox>
                <box hexpand halign={Gtk.Align.START}></box>
                <box>
                    <Time />
                </box>
                <box hexpand halign={Gtk.Align.END}>
                    <StatusIcons />
                </box>
            </centerbox>
        </window>
    );
};

