#!/bin/sh

notify-send "Getting list of available Wi-Fi networks..."

# Use a temporary file to store unique formatted network entries
temp_wifi_list=$(mktemp)

# Variables to hold current network's info as we parse the multiline output
current_ssid=""
current_security=""

# Get network list in multiline mode for easier parsing
# We pipe the output into a while loop to process line by line
nmcli -m multiline --fields SECURITY,SSID device wifi list | while read -r line
do
    # Check if the line contains the SSID label
    if echo "$line" | grep -q "^SSID:"; then
        # Extract the SSID by removing "SSID:" and any leading whitespace
        current_ssid=$(echo "$line" | sed 's/^SSID:\s*//')
        # Trim leading/trailing whitespace from the extracted SSID
        current_ssid=$(echo "$current_ssid" | xargs)
    fi

    # Check if the line contains the SECURITY label
    if echo "$line" | grep -q "^SECURITY:"; then
        # Extract the Security type(s) by removing "SECURITY:" and any leading whitespace
        current_security=$(echo "$line" | sed 's/^SECURITY:\s*//')
        # Trim leading/trailing whitespace from the extracted security field
        current_security=$(echo "$current_security" | xargs)

        # Now that we have both SSID and Security for this network entry, process it
        # Determine the icon based on the security field.
        # If the security field is exactly "--", it's an open network.
        # Otherwise, we assume it is secured.
        if [ "$current_security" = "--" ]; then
            icon="" # Open network icon
        else
            icon="" # Secured network icon
        fi

        # Format the output line with the icon and SSID
        formatted_ssid="$icon $current_ssid"

        # Check if this formatted SSID string (icon + SSID) has already been added to the temporary list.
        # This ensures each unique network is listed only once.
        # Escape special characters in the formatted string for grep
        escaped_formatted_ssid=$(printf '%s' "$formatted_ssid" | sed 's/[][\\.*^$?]/\\&/g')

        # Use grep -q to check if the escaped formatted string exists as a whole line in the temporary file
        if ! grep -q "^${escaped_formatted_ssid}$" "$temp_wifi_list"; then
             # If not found, add the formatted SSID to the temporary list
             echo "$formatted_ssid" >> "$temp_wifi_list"
        fi

        # Reset variables for the next network entry (multiline entries are separated by blank lines or new SSID/SECURITY blocks)
        current_ssid=""
        current_security=""
    fi
    # We don't need an explicit check for blank lines as processing happens when SECURITY is found.

done # End of the while loop reading nmcli output

# Read the unique formatted network entries from the temporary file into wifi_list
wifi_list=$(cat "$temp_wifi_list")

# Clean up the temporary file
rm "$temp_wifi_list"

# --- Rofi Selection and Connection Logic (largely the same) ---

# Check current Wi-Fi radio status
connected=$(nmcli -fields WIFI g)
if [[ "$connected" =~ "enabled" ]]; then
    toggle="󰖪  Disable Wi-Fi"
elif [[ "$connected" =~ "disabled" ]]; then
    toggle="󰖩  Enable Wi-Fi"
fi

# Use rofi to select wifi network. The list includes the toggle option and the unique formatted networks.
# -dmenu: run in dmenu mode
# -i: case-insensitive matching
# -selected-row 1: start with the second item selected (the first network, skipping the toggle)
# -p "Wi-Fi SSID: ": set the Rofi prompt
chosen_network=$(echo -e "$toggle\n$wifi_list" | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: " )

# Get the actual SSID (connection ID) from the selected Rofi entry.
# The Rofi entry is "icon SSID". We remove the first character (the icon) and the following space.
chosen_id=$(echo "$chosen_network" | sed 's/^. //')

# --- Handle the selected option ---
if [ "$chosen_network" = "" ]; then
    # If nothing was selected (user pressed Esc, for example), exit the script.
    exit
elif [ "$chosen_network" = "󰖩  Enable Wi-Fi" ]; then
    # If the user selected to enable Wi-Fi
    nmcli radio wifi on
elif [ "$chosen_network" = "󰖪  Disable Wi-Fi" ]; then
    # If the user selected to disable Wi-Fi
    nmcli radio wifi off
else
    # If the user selected a Wi-Fi network to connect to
    success_message="You are now connected to the Wi-Fi network \"$chosen_id\"."

    # Get the list of saved connections to check if the chosen network is already configured.
    saved_connections=$(nmcli -g NAME connection)

    # Check if the chosen_id exists as an exact match in the list of saved connections.
    # Using grep with line anchors (^) and ($) ensures an exact match.
    if echo "$saved_connections" | grep -q "^${chosen_id}$"; then
        # If the network is a saved connection, attempt to activate it by its ID.
        # We pipe the output to grep to check for the "successfully" message and notify the user.
        nmcli connection up id "$chosen_id" | grep "successfully" && notify-send "Connection Established" "$success_message"
    else
        # If the network is not a saved connection, attempt to connect to it.
        # We need to determine if a password is required based on the icon displayed in Rofi.
        # Check if the selected network line in Rofi started with the secured icon ()
        if [[ "$chosen_network" =~ ^ ]]; then
            # If it's a secured network (indicated by the lock icon), prompt the user for a password using Rofi.
            wifi_password=$(rofi -dmenu -p "Password for $chosen_id: " )
        fi

        # Attempt to connect to the network using its SSID (chosen_id).
        # If a password was entered (i.e., wifi_password is not empty), provide it.
        # nmcli is smart enough to ignore the password if the network is open.
        # We pipe the output to grep to check for the "successfully" message and notify the user.
        # We add a check for -n "$wifi_password" to handle the case where the user cancels the password prompt.
        if [[ -n "$wifi_password" ]]; then
             nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "successfully" && notify-send "Connection Established" "$success_message"
        else
             # If no password was entered (either because it was an open network or the prompt was cancelled),
             # attempt to connect without a password. This is necessary for both open networks and
             # if the user decided not to enter a password for a secured network (which will likely fail unless it's a special case).
              nmcli device wifi connect "$chosen_id" | grep "successfully" && notify-send "Connection Established" "$success_message"
        fi
    fi
fi
