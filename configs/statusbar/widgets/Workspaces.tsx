import { bind } from "astal"
import Hyprland from "gi://AstalHyprland"

export function Workspaces() {
    const hypr = Hyprland.get_default()

    return <box className="Workspaces">
        {bind(hypr, "workspaces").as(wss => wss
            .sort((a, b) => a.id - b.id)
            .map(ws => (
                <button
                    className={bind(hypr, "focusedWorkspace").as(fw =>
                        ws === fw ? "focused" : "not-focused")}
                    onClicked={() => ws.focus()}>
                    {ws.name}
                </button>
            ))
        )}
    </box>
}