import { Variable, bind } from "astal";
import { Gtk } from "astal/gtk3";
import Bluetooth from "gi://AstalBluetooth";
import Network from "gi://AstalNetwork";
import Wp from "gi://AstalWp";
import Popover from "./Popover";

export const StatusIcons = () => {
    const showPopup = Variable(false);
    const bluetooth = Bluetooth.get_default();
    const isPowered = bind(bluetooth, "isPowered");
    const devices = bind(bluetooth, "devices");
    
    const network = Network.get_default();
    const wifiIconName = bind(network, "wifi").as(wifi => wifi?.iconName);
    const wiredIconName = bind(network, "wired").as(wired => wired?.iconName);
    
    const wirePlumberObj = Wp.get_default();
    const speaker = wirePlumberObj!.get_default_speaker();
    if (!speaker) return <box />;
    const soundIconName = bind(speaker, "volumeIcon");
    
    const openPopup = () => showPopup.set(true);
    const closePopup = () => showPopup.set(false);

    return (
        <box>
            <button onClicked={openPopup}>
                <box className="StatusIcons">
                    <icon className='statusIcon' icon={soundIconName} />
                    {bind(network, "primary").as(primary => (
                        primary === "wifi" ? <icon className='statusIcon' icon={wifiIconName} /> : <icon className='statusIcon' icon={wiredIconName} />
                    ))}
                    <icon className='statusIcon' icon="bluetooth" />
                </box>
            </button>
            <Popover valign={Gtk.Align.END} halign={Gtk.Align.END} marginBottom={20} className="Popup" onClose={closePopup} visible={showPopup()}>
                <box className="popup" vertical>
                    <label label="Bluetooth Settings" />
                    <switch active={isPowered} />
                </box>
            </Popover>
        </box>
    );
}

export default StatusIcons;