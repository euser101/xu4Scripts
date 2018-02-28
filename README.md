# xu4Scripts
<h1>Instructions</h1>
<h2>Scripts</h2>
Open Terminal and execute:
<code>git clone https://github.com/euser101/xu4Scripts && cd xu4Scripts</code>
<code>chmod +x *.sh</code>
<code>sudo ./scriptName.sh</code>
<br>
<h2>Files</h2>
Contains Configuration files. Feel free to overwrite my .config (which is already minimal) to use for compiling with the script.
Odroid-Tweaks belongs to a custom systemd-service. The boot.ini was minimalized and tweaked to work with the xu4. Use this file on your own risk.

<h1>Description</h1>
- benchmarkLogger:
Executes Benchmarks to test CPU, RAM, DISK and log the result into a file.<br>
- kernelCompile:
Automatically compile, install, configure a Kernel.<br>
- postBoot:
Configure System after boot, regenerate ssh keys, change passwords etc.<br>
- monitorSoc:
Watch temps and frequencies of CPU. Make sure to use watch as a prefix.<br>

<strong>Credits:</strong> The odroid-tweaks Script that fixed some issues go to [mdrjr](https://github.com/mdrjr/5422_platform). Fan control was added by me.
