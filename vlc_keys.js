// Enables a few keybinds for the VLC web interface:
//
// - space:      pause or play
// - tab:        next track
// - shift+tab:  previous track

(() => {
    // random name to avoid collisions
    if (window.keybinds_UFMmC) {
        return;
    }
    window.keybinds_UFMmC = true;
    addEventListener("keydown", (evt, cmd_name) => {
        if (evt.ctrlKey || evt.altKey || evt.metaKey) return;
        if (!(cmd_name = {
            " ": "pause",
            "Tab": evt.shiftKey ? "previous" : "next",
        }[evt.key])) return;
        sendCommand({command: "pl_" + cmd_name});
        evt.preventDefault();
    });
})();
