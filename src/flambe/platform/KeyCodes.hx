//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.Key;

/**
 * Key codes emitted by Flash and JS.
 */
class KeyCodes
{
    public static inline var A = 65;
    public static inline var B = 66;
    public static inline var C = 67;
    public static inline var D = 68;
    public static inline var E = 69;
    public static inline var F = 70;
    public static inline var G = 71;
    public static inline var H = 72;
    public static inline var I = 73;
    public static inline var J = 74;
    public static inline var K = 75;
    public static inline var L = 76;
    public static inline var M = 77;
    public static inline var N = 78;
    public static inline var O = 79;
    public static inline var P = 80;
    public static inline var Q = 81;
    public static inline var R = 82;
    public static inline var S = 83;
    public static inline var T = 84;
    public static inline var U = 85;
    public static inline var V = 86;
    public static inline var W = 87;
    public static inline var X = 88;
    public static inline var Y = 89;
    public static inline var Z = 90;

    public static inline var NUMBER_0 = 48;
    public static inline var NUMBER_1 = 49;
    public static inline var NUMBER_2 = 50;
    public static inline var NUMBER_3 = 51;
    public static inline var NUMBER_4 = 52;
    public static inline var NUMBER_5 = 53;
    public static inline var NUMBER_6 = 54;
    public static inline var NUMBER_7 = 55;
    public static inline var NUMBER_8 = 56;
    public static inline var NUMBER_9 = 57;

    public static inline var NUMPAD_0 = 96;
    public static inline var NUMPAD_1 = 97;
    public static inline var NUMPAD_2 = 98;
    public static inline var NUMPAD_3 = 99;
    public static inline var NUMPAD_4 = 100;
    public static inline var NUMPAD_5 = 101;
    public static inline var NUMPAD_6 = 102;
    public static inline var NUMPAD_7 = 103;
    public static inline var NUMPAD_8 = 104;
    public static inline var NUMPAD_9 = 105;

    public static inline var NUMPAD_ADD = 107;
    public static inline var NUMPAD_DECIMAL = 110;
    public static inline var NUMPAD_DIVIDE = 111;
    public static inline var NUMPAD_ENTER = 108;
    public static inline var NUMPAD_MULTIPLY = 106;
    public static inline var NUMPAD_SUBTRACT = 109;

    public static inline var F1 = 112;
    public static inline var F2 = 113;
    public static inline var F3 = 114;
    public static inline var F4 = 115;
    public static inline var F5 = 116;
    public static inline var F6 = 117;
    public static inline var F7 = 118;
    public static inline var F8 = 119;
    public static inline var F9 = 120;
    public static inline var F10 = 121;
    public static inline var F11 = 122;
    public static inline var F12 = 123;
    public static inline var F13 = 124;
    public static inline var F14 = 125;
    public static inline var F15 = 126;

    public static inline var LEFT = 37;
    public static inline var UP = 38;
    public static inline var RIGHT = 39;
    public static inline var DOWN = 40;

    public static inline var ALT = 18;
    public static inline var BACKQUOTE = 192;
    public static inline var BACKSLASH = 220;
    public static inline var BACKSPACE = 8;
    public static inline var CAPS_LOCK = 20;
    public static inline var COMMA = 188;
    public static inline var COMMAND = 15;
    public static inline var CONTROL = 17;
    public static inline var DELETE = 46;
    public static inline var END = 35;
    public static inline var ENTER = 13;
    public static inline var EQUALS = 187;
    public static inline var ESCAPE = 27;
    public static inline var HOME = 36;
    public static inline var INSERT = 45;
    public static inline var LEFT_BRACKET = 219;
    public static inline var MINUS = 189;
    public static inline var PAGE_DOWN = 34;
    public static inline var PAGE_UP = 33;
    public static inline var PERIOD = 190;
    public static inline var QUOTE = 222;
    public static inline var RIGHT_BRACKET = 221;
    public static inline var SEMICOLON = 186;
    public static inline var SHIFT = 16;
    public static inline var SLASH = 191;
    public static inline var SPACE = 32;
    public static inline var TAB = 9;

    // Android keys (AIR only)
    public static inline var BACK = 0x01000016;
    public static inline var MENU = 0x01000012;
    public static inline var SEARCH = 0x0100001f;

    public static function toKey (keyCode :Int) :Key
    {
        switch (keyCode) {
            case A: return Key.A;
            case B: return Key.B;
            case C: return Key.C;
            case D: return Key.D;
            case E: return Key.E;
            case F: return Key.F;
            case G: return Key.G;
            case H: return Key.H;
            case I: return Key.I;
            case J: return Key.J;
            case K: return Key.K;
            case L: return Key.L;
            case M: return Key.M;
            case N: return Key.N;
            case O: return Key.O;
            case P: return Key.P;
            case Q: return Key.Q;
            case R: return Key.R;
            case S: return Key.S;
            case T: return Key.T;
            case U: return Key.U;
            case V: return Key.V;
            case W: return Key.W;
            case X: return Key.X;
            case Y: return Key.Y;
            case Z: return Key.Z;

            case NUMBER_0: return Key.Number0;
            case NUMBER_1: return Key.Number1;
            case NUMBER_2: return Key.Number2;
            case NUMBER_3: return Key.Number3;
            case NUMBER_4: return Key.Number4;
            case NUMBER_5: return Key.Number5;
            case NUMBER_6: return Key.Number6;
            case NUMBER_7: return Key.Number7;
            case NUMBER_8: return Key.Number8;
            case NUMBER_9: return Key.Number9;

            case NUMPAD_0: return Key.Numpad0;
            case NUMPAD_1: return Key.Numpad1;
            case NUMPAD_2: return Key.Numpad2;
            case NUMPAD_3: return Key.Numpad3;
            case NUMPAD_4: return Key.Numpad4;
            case NUMPAD_5: return Key.Numpad5;
            case NUMPAD_6: return Key.Numpad6;
            case NUMPAD_7: return Key.Numpad7;
            case NUMPAD_8: return Key.Numpad8;
            case NUMPAD_9: return Key.Numpad9;

            case NUMPAD_ADD: return Key.NumpadAdd;
            case NUMPAD_DECIMAL: return Key.NumpadDecimal;
            case NUMPAD_DIVIDE: return Key.NumpadDivide;
            case NUMPAD_ENTER: return Key.NumpadEnter;
            case NUMPAD_MULTIPLY: return Key.NumpadMultiply;
            case NUMPAD_SUBTRACT: return Key.NumpadSubtract;

            case F1: return Key.F1;
            case F2: return Key.F2;
            case F3: return Key.F3;
            case F4: return Key.F4;
            case F5: return Key.F5;
            case F6: return Key.F6;
            case F7: return Key.F7;
            case F8: return Key.F8;
            case F9: return Key.F9;
            case F10: return Key.F10;
            case F11: return Key.F11;
            case F12: return Key.F12;

            case LEFT: return Key.Left;
            case UP: return Key.Up;
            case RIGHT: return Key.Right;
            case DOWN: return Key.Down;

            case ALT: return Key.Alt;
            case BACKQUOTE: return Key.Backquote;
            case BACKSLASH: return Key.Backslash;
            case BACKSPACE: return Key.Backspace;
            case CAPS_LOCK: return Key.CapsLock;
            case COMMA: return Key.Comma;
            case COMMAND: return Key.Command;
            case CONTROL: return Key.Control;
            case DELETE: return Key.Delete;
            case END: return Key.End;
            case ENTER: return Key.Enter;
            case EQUALS: return Key.Equals;
            case ESCAPE: return Key.Escape;
            case HOME: return Key.Home;
            case INSERT: return Key.Insert;
            case LEFT_BRACKET: return Key.LeftBracket;
            case MINUS: return Key.Minus;
            case PAGE_DOWN: return Key.PageDown;
            case PAGE_UP: return Key.PageUp;
            case PERIOD: return Key.Period;
            case QUOTE: return Key.Quote;
            case RIGHT_BRACKET: return Key.RightBracket;
            case SEMICOLON: return Key.Semicolon;
            case SHIFT: return Key.Shift;
            case SLASH: return Key.Slash;
            case SPACE: return Key.Space;
            case TAB: return Key.Tab;

            case MENU: return Key.Menu;
            case SEARCH: return Key.Search;
        }

        return Unknown(keyCode);
    }

    public static function toKeyCode (key :Key) :Int
    {
        switch (key) {
            case Key.A: return A;
            case Key.B: return B;
            case Key.C: return C;
            case Key.D: return D;
            case Key.E: return E;
            case Key.F: return F;
            case Key.G: return G;
            case Key.H: return H;
            case Key.I: return I;
            case Key.J: return J;
            case Key.K: return K;
            case Key.L: return L;
            case Key.M: return M;
            case Key.N: return N;
            case Key.O: return O;
            case Key.P: return P;
            case Key.Q: return Q;
            case Key.R: return R;
            case Key.S: return S;
            case Key.T: return T;
            case Key.U: return U;
            case Key.V: return V;
            case Key.W: return W;
            case Key.X: return X;
            case Key.Y: return Y;
            case Key.Z: return Z;

            case Key.Number0: return NUMBER_0;
            case Key.Number1: return NUMBER_1;
            case Key.Number2: return NUMBER_2;
            case Key.Number3: return NUMBER_3;
            case Key.Number4: return NUMBER_4;
            case Key.Number5: return NUMBER_5;
            case Key.Number6: return NUMBER_6;
            case Key.Number7: return NUMBER_7;
            case Key.Number8: return NUMBER_8;
            case Key.Number9: return NUMBER_9;

            case Key.Numpad0: return NUMPAD_0;
            case Key.Numpad1: return NUMPAD_1;
            case Key.Numpad2: return NUMPAD_2;
            case Key.Numpad3: return NUMPAD_3;
            case Key.Numpad4: return NUMPAD_4;
            case Key.Numpad5: return NUMPAD_5;
            case Key.Numpad6: return NUMPAD_6;
            case Key.Numpad7: return NUMPAD_7;
            case Key.Numpad8: return NUMPAD_8;
            case Key.Numpad9: return NUMPAD_9;

            case Key.NumpadAdd: return NUMPAD_ADD;
            case Key.NumpadDecimal: return NUMPAD_DECIMAL;
            case Key.NumpadDivide: return NUMPAD_DIVIDE;
            case Key.NumpadEnter: return NUMPAD_ENTER;
            case Key.NumpadMultiply: return NUMPAD_MULTIPLY;
            case Key.NumpadSubtract: return NUMPAD_SUBTRACT;

            case Key.F1: return F1;
            case Key.F2: return F2;
            case Key.F3: return F3;
            case Key.F4: return F4;
            case Key.F5: return F5;
            case Key.F6: return F6;
            case Key.F7: return F7;
            case Key.F8: return F8;
            case Key.F9: return F9;
            case Key.F10: return F10;
            case Key.F11: return F11;
            case Key.F12: return F12;
            case Key.F13: return F13;
            case Key.F14: return F14;
            case Key.F15: return F15;

            case Key.Left: return LEFT;
            case Key.Up: return UP;
            case Key.Right: return RIGHT;
            case Key.Down: return DOWN;

            case Key.Alt: return ALT;
            case Key.Backquote: return BACKQUOTE;
            case Key.Backslash: return BACKSLASH;
            case Key.Backspace: return BACKSPACE;
            case Key.CapsLock: return CAPS_LOCK;
            case Key.Comma: return COMMA;
            case Key.Command: return COMMAND;
            case Key.Control: return CONTROL;
            case Key.Delete: return DELETE;
            case Key.End: return END;
            case Key.Enter: return ENTER;
            case Key.Equals: return EQUALS;
            case Key.Escape: return ESCAPE;
            case Key.Home: return HOME;
            case Key.Insert: return INSERT;
            case Key.LeftBracket: return LEFT_BRACKET;
            case Key.Minus: return MINUS;
            case Key.PageDown: return PAGE_DOWN;
            case Key.PageUp: return PAGE_UP;
            case Key.Period: return PERIOD;
            case Key.Quote: return QUOTE;
            case Key.RightBracket: return RIGHT_BRACKET;
            case Key.Semicolon: return SEMICOLON;
            case Key.Shift: return SHIFT;
            case Key.Slash: return SLASH;
            case Key.Space: return SPACE;
            case Key.Tab: return TAB;

            case Key.Menu: return MENU;
            case Key.Search: return SEARCH;

            case Key.Unknown(keyCode): return keyCode;
        }
    }
}
