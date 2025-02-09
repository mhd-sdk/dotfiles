import { App, Astal } from "astal/gtk3"
import style from "./style.scss"
import { Bar } from "./widgets/Bar"
const { TOP, RIGHT, LEFT } = Astal.WindowAnchor

App.start({
    css: style,
    instanceName: "statusbar",
    requestHandler(request, res) {
        print(request)
        res("ok")
    },
    main: () => {
        // render the status bar on all monitors
        App.get_monitors().map(Bar)
    }

})