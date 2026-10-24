{ pkgs, ... }:

{
    programs.hyprlock = {
      enable = true;
      settings = {
        source = [ "$HOME/.config/hypr/mocha.conf" ];

        general.hide_cursor = true;

        background = [{
          monitor = "";
          path = "$HOME/.config/hypr/nix-wallpaper-nineish-catppuccin-mocha-alt.png";
          blur_passes = 0;
          color = "$base";
        }];

        label = [
          {
            monitor = "";
            text = "Layout: $LAYOUT";
            color = "$text";
            font_size = 15;
            font_family = "Iosevka Nerd Font";
            position = "30, -30";
            halign = "left";
            valign = "top";
          }
          {
            monitor = "";
            text = "$TIME";
            color = "$text";
            font_size = 90;
            font_family = "Iosevka Nerd Font";
            position = "-30, 0";
            halign = "right";
            valign = "top";
          }
          {
            monitor = "";
            text = "cmd[update:43200000] date +\"%A, %d %B %Y\"";
            color = "$text";
            font_size = 25;
            font_family = "Iosevka Nerd Font";
            position = "-30, -150";
            halign = "right";
            valign = "top";
          }
          {
            monitor = "";
            text = "$FPRINTPROMPT";
            color = "$text";
            font_size = 14;
            font_family = "Iosevka Nerd Font";
            position = "0, -107";
            halign = "center";
            valign = "center";
          }
        ];

        image = [{
          monitor = "";
          path = "$HOME/.face";
          size = 100;
          border_color = "$mauve";
          position = "0, 75";
          halign = "center";
          valign = "center";
        }];

        input-field = [{
          monitor = "";
          size = "300, 60";
          outline_thickness = 4;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          outer_color = "$mauve";
          inner_color = "$surface0";
          font_color = "$text";
          fade_on_empty = false;
          placeholder_text = "<span foreground=\"##$textAlpha\"><i>󰌾 Logged in as </i><span foreground=\"##$mauveAlpha\">$USER</span></span>";
          hide_input = false;
          check_color = "$mauve";
          fail_color = "$red";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          capslock_color = "$yellow";
          position = "0, -47";
          halign = "center";
          valign = "center";
        }];
      };
    };
}
