ec2-for-econometricians
==============================
This is a rough guide to Amazon EC2 targeted at econometricians who want to run parallel simulations in the cloud.

Understanding Instance Pricing
------------------------------
Amazon EC2 offers three types of instances: on-demand instances, spot instances, and reserved instances.
Reserved instances aren't really relevant for academic use, so I'll only describe the first two kinds here.

On-demand instances are just what they say: instances that you can spin up more or less immediately, as you need them.
Prices are set by region (the nearest to Penn is US East) and vary at the time of this writing from as little as 1.3 cents per hour for a t2.micro instance with a single core and 1 GB of RAM to nearly 3 dollars per hour for a g2.8xlarge instance equipped with 32 cores, a state-of-the-art GPU and 60 GB of RAM.
Up-to-date pricing is available [here](https://aws.amazon.com/ec2/pricing/).
As a rule there's pretty much no waiting in line for on-demand instances: your machine will be available within a couple of minutes.

Unlike on-demand instances, spot instances have prices that vary continuously in line with demand.
Typically they're *much* lower than on-demand prices.
For example, I typically pay around 24 cents per hour for a 32 core spot instance.
To access spot instances you first place a *bid*.
As long as your bid exceeds the current spot price, your instance will remain available.
If the spot price rises above your bid, however, you instance can be terminated without warning.
If your machine is cut off in the middle of an hour, you won't be billed for that hour.
Personally, I've never had a spot instance cut out on me but then again I've never run anything for longer than a few hours.
Another important difference between on-demand and spot instances is that, while on-demand instances can either be *stopped* or *terminated*, spot instances can *only* be terminated.
There's more information on this point in the [AWS documentation](http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_StopInstances.html).
This makes working with spot instances slightly more irritating than working with on-demand instances a bit simpler than working with spot instances.
As I'll describe below, by stopping and starting on-demand instances you can pick up exactly where you left off without being charged for computational resources when you're not using them.
With spot instances things are a bit more complicated.

Stopping versus Terminating
----------------------------
After you've started them, on-demand instances can either be *stopped* or *terminated*.
By default, when you terminate an instance *everything is deleted*.
(As I'll discuss below, it is possible to override this behavior.)
In contrast, a *stopped instance* can be re-started at will and you can pick up exactly where you left off without being charged for computational resources that you didn't use in between.

A Word about Regions
--------------------
The EC2 control panel is *region-specific*. 
In the top right-hand corner there's a dropdown menu to choose your region.
Among the options are US East (N. Virginia), US West (Oregon) and various overseas locations.
You can set up instances and AMIs in various regions but you'll only be able to view them after you've selected the region in which you created them.
For example, if you start an instance in the US West (Oregon) region and then switch over to US East (N. Virginia), it won't appear under **Instances**. 
The easiest way to avoid confusion is to choose a region and stick with it.
The closest one to us at Penn is US East, so I suggest that you always work with this one.

Launching Your First Instance
-----------------------------
Now that you have an AWS account, it's time to create your very first EC2 instance.

1. Go to the EC2 control panel and click **Instances** followed by **Launch Instance**.
2. You'll be taken to a page that says "Step 1: Choose an Amazon Machine Image (AMI)" with the "Quick Start" pane selected.
Scroll down to "Ubuntu Server 14.04 LTS" (the fourth option) and click **Select**.
3. You'll now be taken to "Step 2: Choose an Instance Type." 
The first option "General purpose t2.micro" should already be selected.
If it isn't, click on it, and then click "Review and Launch. 
4. You'll now be taken to "Step 7: Review Instance Launch." 
Click **Launch** at the bottom right-hand side of the screen.
5. A dialog box will pop up instructing you to select an existing key pair or create a new one.
If this is your first time using EC2 you'll need to create a new key pair.
You should *never* proceed without a key pair.
Choose "Create a new key pair" from the pull-down menu, enter a name for the key pair in the text field and click "Download Key."
It may take a few seconds to generate the key.
For the moment save it somewhere easily accessible, like your desktop.
*Don't lose the key or you won't be able to access your instance and will have to start all over again!*
After you've set up a key pair, you'll be able to re-use it in the future.
6. Check the box marked "I acknowledge that..." and then click **Launch Instances** followed by **View Instances**. You should see a t2.micro instance listed with Instance State "pending." After a short time this will switch to "running." When this happens, your instance is ready to go. 

So what just happened?
When you want to start an instance you need to do three things: choose an AMI, choose an instance type, and set up security.
These are important concepts in their own right, so it's worth spending a little time understanding how they work.

An AMI is an *Amazon Machine Image*.
Without an AMI, an instance is just a bare machine with no software of any kind.
To actually be able to *use* an instance, you'll need at least an operating system.
Essentially an AMI is a bootable disk image containing and operating system and (possibly) other pieces of software that you might want to use.
Various AMIs are available, both from Amazon and third parties, and you can even create your own.
What we did above was select one of Amazon's default Linux AMIs (Ubuntu Server 14.04 LTS).
Ubuntu is a good choice as it's arguably the most widely-used flavor of Linux, making it very easy to find help online.
Ubuntu 14.04 is rock-solid and will be supported for the next four years: it's what I run at home.
This AMI is pretty bare-bones: it doesn't have much more than the operating system and some basic tools.
If we want to use R, for example, we'll need to install it.
Don't worry: this isn't hard.
In one of the sections that follows I'll show you how to use this AMI as a base upon which to build a custom AMI of your own.

The second thing we did was choose an instance type.
Whereas an AMI specifies the *software* you want to make available, the instance type specifies the *hardware*.
There are many possibilities here but for our purposes this is really a question of how many cores and how much RAM you need.
A full description of instance types is available [here](https://aws.amazon.com/ec2/instance-types/).
Unsurprisingly, more cores means a higher charge per hour but pricing is linear: one core for ten hours costs the same as ten cores for one hour.
For this example I selected the puniest possible instance type the t2.micro General Purpose instance.
This is the cheapest possible instance: at the time of this writing it costs about 1.3 cents per hour.
For up-to-date pricing in the US East (N. Virgina) region, click [here](https://aws.amazon.com/ec2/pricing/).
The t2.micro is ideal for learning how to use EC2.
For computationally intensive work, however, you'll want access to faster processers, more cores and more RAM.
The two families of instance type that make the most sense for us are the Compute Optimized C4 family (up to 36 cores and 60 GB of RAM) and possibly in some cases the G2 family of instances, which include up to 4 high-performance NVIDIA GPUs, each with 1536 CUDA cores and 4GB of video memory.
As you might expect, these machines are much pricier, but you can often get a very good deal by using spot instances, as I'll describe in more detail below.

The final step in setting up an instance is setting up security.
The point is to ensure that you and only you can access the instance you've created.
This is precisely what creating a keypair does.
In the next section I'll show you how to use your key to access your instance via ssh.

Accessing Your Instance For the First Time
-------------------------------------------
In the preceding section we launched a Linux instance.
To actually do anything with our instance we'll need to connect to it and this will require using some command line tools.
If you've never worked with a UNIX-like terminal before, you may find it helpful to brush up on a couple of basics.
The game [Terminus](http://web.mit.edu/mprat/Public/web/Terminus/Web/main.html) is a fun, browser-based introduction to the command line, somewhat in the style of Oregon Trail.
William Schott's book [The Linux Command Line](http://linuxcommand.org/tlcl.php) is also fantastic and free!


The most reliable way to acces your instance is by using an ssh client.
If you're running Mac or Linux, you already have one installed that you can run from a terminal window.
I'll explain how to do this below.
If you're on Windows, life is a bit more complicated.
Essentially you have two options.
The first is to connect to your instance using your browser.
I've never tried this before, but supposedly if you have Java installed you can select your instance from the EC2 control panel and click the button marked **Connect**.
This will run a terminal emulator in your browser that will ask for the location of the key you created above.
For more details, click [here](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-connect-to-instance-linux.html#using-browser).
Another option for Windows folks is to use a program called [PuTTY](http://www.putty.org), a free SSH and telnet client.
This program comes highly recommended to me, but I've never used it before.
One twist if you choose this option is that you'll have to convert your key to a formal that PuTTY can understand.
Full instructions are available [here](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html).

For the rest of this section I'll assume that you're on Mac or Linux.
If you're on Windows you'll have to adapt these instructions slightly following the information at the links given above.

1. Open a terminal. If you're on Linux I'll assume you know how to do this. If you're on Mac, go to spotlight and type "Terminal" before pressing return. You should see a black window with a command prompt.
2. In this step we'll move the key you created above to the "hidden" ``.ssh`` directory to keep it safe from prying eyes. My key is called ``my-key.pem`` and is currently on my desktop. I move it to the appropriate directory as follows: 

        mv ~/Desktop/my-key.pem ~/.ssh
We can check that this worked by viewing the contents of the ``.ssh`` directory as follows:

        ls ~/.ssh
On my machine after running this command I see, among other things, ``my-key.pem`` which I just moved to this directory.
If you're using this particular key for the first time you'll also need to do the following:

        chmod 400 ~/.ssh/my-key.pem
where, instead of ``my-key.pem`` you should use whatever name you gave your key when you created it.
4. Finally we're ready to connect to the instance!
Go to the EC2 control panel, click **Instances** and then click on the instance you want. (At this point there should be only one and it should have a green light under instance state.)
Now look down towards the bottom of the page and find the field "Public IP."
This will be a series of numbers separated by periods.
For example it might be 12.3.4.55 or something similar.
This is the *unique* address that you will use to access your instance.
Every time you create a new instance you should expect it to have a *different* Public IP. 
Using your Public IP, you can access your machine via ssh as follows:

        ssh -i ~/.ssh/my-key.pem ubuntu@PublicIP
where ``PublicIP`` is the public IP address of your instance.
After hitting return, you may be asked whether you want to trust this connection.
Enter yes.
A few seconds later your command prompt should change so it starts with ``ubuntu@``. 
You are now connected via ssh to your machine!

Your instance is pretty much empty except for basic command line tools.
If you type ``ls`` to list all the files in your home directory it won't list anything since there's nothing to list!
Let's remedy this by installing R so we can do a simple calculation:

        sudo apt-get update
        sudo apt-get install -y r-base
Text will flash across the screen for a while but after a minute or so you'll be back to your command prompt.
If you enter ``R`` you'll launch an R terminal session. 
To quit enter ``q()`` and choose ``n``.
To disconnect from your instance type ``exit`` at the Linux command prompt.
Your command prompt should change as you're now connected to your local machine rather than the instance.
Finally, go to the EC2 control panel, click **Instances**, click on your instance and then click **Actions** followed by **Instance State** and then **Terminate**.
Amazon will ask if you're sure: once you terminate an instance, everything on it will be deleted.
This is unlike *stopping* an instance, which we'll discuss below.

Starting Up Your *Second* Instance
-----------------------------------
The next time you want to launch and connect to an instance, you can re-use the key you've already created, thus skipping several steps.
After you've selected an AMI and instance type you'll be given the option to "Choose an existing key pair."
This time there's nothing to download: you can simply launch the instance.
Once it's up and running and you know its Public IP, you can connect to it as follows:

        ssh -i ~/.ssh/my-key.pem ubuntu@PublicIP

Creating a Amazon Machine Image (AMI)
--------------------------------------

1. Launch a t2.micro instance using Amazon's Ubuntu Server 14.04 LTS AMI as above.
2. Log into the instance and install whatever software you want. I'll install ``R``, ``Rcpp``, ``RcppArmadillo``, ``git``, ``tmux`` and ``htop`` as follows:

        sudo apt-get update
        sudo apt-get install -y git
        sudo apt-get install -y r-base
        sudo apt-get install -y r-cran-rcpp
        sudo apt-get install -y r-cran-rcpparmadillo
        sudo apt-get install -y tmux
        sudo apt-get install -y htop
3. Go to **Instances** in the EC2 console, click the instance on which you've installed the software you want, then click **Actions** followed by **Image** and **Create Image**.
4. Fill out the required information, giving a name and optionally a description to your instance before clicking **Create Image**. (*Don't* select **No reboot**.) When you do this, your ssh connection will be closed. Don't be alarmed: this is what's supposed to happen!
5. Under **AMIs** in the navigation pane, you should now see that your AMI is *pending*. After a few minutes it will be *available*. Unless you want to use it for some other purpose, you can now terminate the instance you started in Step 1 from the control panel by clicking on the instance followed by *Actions*, *Instance State* and *Terminate*.
6. Once your AMI is available, you'll be able to boot it up on any instance you like: click **AMIs** then select the AMI you want and click **Launch**. You'll be taken immediately to Step 2 of the instance configuration process where you'll be able to choose the kind of instance on which you want to boot your AMI. Note that it *needn't* be a t2.micro instance even though this was the kind of instance we used to create the AMI. Notice that the name you gave your AMI will appear under *Instances*, *Description* when you've started your instance.

Once you have an AMI, you can keep it around as long as you like, or delete it. 
If you follow my instructions from above, you'll end up with an 8GB instance for which Amazon will charge you (at the time of this writing) 80 cents per month as long as you keep it hanging around.
To *delete* an AMI that you've created and no longer need, follow these steps:

1. Choose AMIs from the control panel and then click on the AMI you want to delete.
2. Click **Actions** and then **Deregister** followed by **Continue**. The AMI will disappear from the list.
3. Click on **Snapshots** from the control panel and select the snapshot whose name matches the AMI you just de-registered. Finally click **Actions** followed by **Delete**.
Fractions of a month are billed hourly.
For more information on creating AMIs, see the [AWS documentation](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/creating-an-ami-ebs.html).





Alarms and Alerts
------------------
One slightly scary thing about AWS is that it is technically possible for you to spend an unlimited amount of money by mistake.
If you do this, Amazon *will charge you* so it's best to take precautions to make sure this can't happen.
I recommend two layers of safety.

First is a billing alert.
If you set up a billing alert, you'll get an email whenever your AWS bill goes above a pre-specified amount, e.g. 10 dollars.
This is a *global* alert that applies to anything you might be spending money on: instances, storage of AMIs, etc.

Second is an alarm that automatically stops idle instances.
When you stop an instance, Amazon [doesn't charge](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Stop_Start.html) you for stopped instances.
They only charge for storing the contents of the that instance on EBS, which is extremely inexpensive (see below).
Instances could easily cost over a dollar per hour, but EBS volumes are around ten cents per GB per month.
Unlike billing alerts, alarms are *instance-specific*. In other words, you need to set them up for each instance on which you want to use them.

I suggest that whenever you start an instance, you set an alarm that automatically stops the instance whenever its CPU usage falls below 10% for more than 5 minutes.
Doing this has two advantages: first is prevents you from accidentally leaving an expensive instance running when you're not using it, and second it can be used as a way of automatically terminating your instance after you've finished your simulation experiment.
Remember: stopping an instance is *different* from terminating one.
A stopped instance can be re-started right where you left off, but your only charged for storage when it's not running.
Here's how to set the alarm for an instance that you already have running:

1. Go to the EC2 control panel, click **Instances** and select the instance you want. Then click **Actions** followed by **CloudWatch Monitoring** and **Add/Edit Alarms**.
2. A dialog box will pop up. Click **Create Alarm** and fill out the details. I suggest "Whenever Average of CPU Utilization Is less than 10 percent for at least 1 consecutive period(s) of 5 minutes."
3. Check the option "Take the action:" and select "Stop"
4. Click **Create Alarm""

Form more information, see the [AWS Documentation](http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/UsingAlarmActions.html).

Using a Terminal Multiplexer (tmux)
------------------------------------
You've accessed your instance via ssh and are running a lengthly calculation.
Just then the Wi-fi network you're working from starts behaving strangely and your ssh connection cuts out.
You re-connect to your instance and are surprised to find that your simulation has stopped running!
What gives?!

When connected via ssh to a remote machine, any processes that haven't finished running when your connection cuts out will be *terminated*. 
The machine is still sitting there, waiting to do your bidding, but anything that hadn't finished running will be lost.
This is far from ideal, but fortunately there's a solution: tmux.
Now let's try a little example.

First launch and connect to a t2.micro instance.
If the AMI you're using doesn't already have R and git, install them first: 

        sudo apt-get update
        sudo apt-get install -y r-base
        sudo apt-get install -y git
Then clone *this repository* as follows:

        git clone https://github.com/fditraglia/ec2-for-econometricians.git
You'll now have a directory called ``ec2-for-econometricians`` containing, this document along with a few R source files.
For this example we'll use the script ``sleep_csv.R`` whose contents are as follows:

        out <- data.frame(1:10, 10:1)
        Sys.sleep(30)
        setwd("~/")
        write.csv(out, file = 'results.csv')
All this script does is create a very simple dataframe, wait for thirty seconds, and then write it to the user's home directory.
This is intended to mimic a simulation study or something similar that takes some time to finish running.

To learn more about tmux, try [this reference](https://danielmiessler.com/study/tmux/) and the [official documentation](http://tmux.sourceforge.net).

Elastic Block Storage
----------------------
If you create an instance and terminate it everything on that machine *will be deleted* **unless** you've set up persistent storage.
Fortunately this is easy and cheap using Elastic Block Storage (EBS).
At the time of this writing, new AWS users are entitled to 30GB of EBS storage per month for free. (For more details click [here](http://aws.amazon.com/free/).)
Even if you're not on the free tier, the prices are still very reasonable: at the moment [ten cents](https://aws.amaxon.com/ebs/pricing) per GB per month.
Like EC2, EBS is billed *hourly* so unless you create very large volumes and keep them around for a very long time, this will cost [next to nothing](http://serverfault.com/questions/197379/amazon-ebs-charges-calculation).

When you create an instance, you'll have an option to add storage in Step 4 of the process.
You'll need to choose how many GB to allocate, what kind of storage you want (general purpose is fine for what we'll be doing) and whether you want the volume to persist after you terminate the instance. 
