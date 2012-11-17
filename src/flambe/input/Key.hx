//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.input;

/**
 * All the possible keyboard keys that can be handled. Use Unknown to handle any platform-specific
 * key codes not yet supported here.
 */
enum Key
{
    A; B; C; D; E; F; G; H; I; J; K; L; M; N; O; P; Q; R; S; T; U; V; W; X; Y; Z;

    Number0; Number1; Number2; Number3; Number4; Number5; Number6; Number7; Number8; Number9;

    Numpad0; Numpad1; Numpad2; Numpad3; Numpad4; Numpad5; Numpad6; Numpad7; Numpad8;
    Numpad9; NumpadAdd; NumpadDecimal; NumpadDivide; NumpadEnter; NumpadMultiply;
    NumpadSubtract;

    F1; F2; F3; F4; F5; F6; F7; F8; F9; F10; F11; F12; F13; F14; F15;

    Left; Up; Right; Down;

    Alt; Backquote; Backslash; Backspace; CapsLock; Comma; Command; Control; Delete; End; Enter;
    Equals; Escape; Home; Insert; LeftBracket; Minus; PageDown; PageUp; Period; Quote; RightBracket;
    Semicolon; Shift; Slash; Space; Tab;

    // Android keys
    Menu; Search;

    /**
     * Used if the environment sends an unknown key code.
     */
    Unknown (keyCode :Int);
}
