# Battlestation

Battlestation is a set of scripts designed to help manage VirtualBox VMs on a public network such that the VMs can be used as training tools for security and penetration testing.

Note that there is an inherent risk of running vulnerable VMs on a public network. The host computer should not be used for other purposes and should not have any personal information stored on the device.
Make sure to back the device up completely before any session involving a group of people in a public network.

## App Installation And Erlang/Elixir Installation

### For Ubuntu

1. `sudo apt install git`
1. `git clone https://github.com/jwdotjs/battlestation.git <path_to_desired_folder>`
1. `wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb`
1. `sudo apt-get update`
1. `sudo apt-get install esl-erlang`
1. `sudo apt-get install elixir`
1. `sudo apt install npm`


### Other OS

[Installation Instructions](https://elixir-lang.org/install.html)

## Installing VirtualBox

[Installation Instructions](https://www.virtualbox.org/wiki/Linux_Downloads)

## Getting VMs

[Download VMs from VulnHub](https://www.vulnhub.com/)

## Making VMs Accessible To The Network

Change the network adapter to use `Bridge`

## Starting The App

To start your Phoenix app:

  * Install Elixir dependencies with `make install`
  * Install Javascript dependencies with `npm install`
  * Start Phoenix endpoint with `make iex`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Before Starting VMs On A Public Network

- Make sure the host computer is backed up
- Make sure you are behind a NAT
- Make sure your VMs are snapshotted and running

