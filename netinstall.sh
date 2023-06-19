#!/bin/zsh

# Check if the Macvlan name is provided as a command-line argument
if [[ -z $1 ]]; then
  echo "Please provide a name for the Macvlan interface as a command-line argument."
  exit 1
fi

macvlan_name=$1

# Check if a Macvlan network with the provided name already exists
existing_macvlan=$(ip link show type macvlan | awk -F ": " '{print $2}' | grep -w "$macvlan_name")
if [[ -n $existing_macvlan ]]; then
  echo "A Macvlan network with the name '$macvlan_name' already exists."
  exit 1
fi

interfaces_netcheck=$(ip link show | awk -F': ' '/^[0-9]+:/{print $2}')  # Get list of interfaces

host="yahoo.com"  # Specify a known external host

for interface in $interfaces_netcheck; do
  ping -c 1 -I "$interface" "$host" >/dev/null 2>&1

  if [ $? -eq 0 ]; then
    echo "Interface $interface can access the internet."
    desired_interface=$interface
    break
  else
    echo "Interface $interface cannot access the internet."
  fi
done

# Check if any network interfaces are available
if [[ -z $desired_interface ]]; then
  echo "No intetrnet capable network interfaces found on the host."
  exit 1
fi

# Get the IP address and subnet of the desired interface
ip_subnet=$(ipconfig getifaddr "$desired_interface")
subnet_prefix_length=$(ipconfig getoption "$desired_interface" subnet_mask | awk '{print $2}')
ip_subnet="$ip_subnet/$subnet_prefix_length"

# Get the gateway IP address
gateway=$(route -n get default | awk '/gateway:/{print $2}')

# Create the Macvlan interface
sudo ip link add link "$desired_interface" name "$macvlan_name" type macvlan mode bridge

# Assign the IP address and gateway to the Macvlan interface
sudo ip addr add "$ip_subnet" dev "$macvlan_name"
sudo ip route add default via "$gateway" dev "$macvlan_name"

echo "Macvlan interface '$macvlan_name' has been created with the following configuration:"
echo "IP Address: $ip_subnet"
echo "Gateway: $gateway"
