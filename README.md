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
6. Click **Launch Instances** followed by **View Instances**. You should see a t2.micro instance listed with Instance State "pending." After a short time this will switch to "running." Once the field "Status Checks" changes from "Initializing" to "???", your instance it ready to use. 

So what just happened?
Without an AMI, an instance is just a bare machine with no software of any kind.
An AMI includes an operating system and various other pieces of software to allow you to actually *use* an instance.
Various AMIs are available but I suggest that you start with the Ubuntu Server 14.04 AMI provided by Amazon and then customize it to meet your needs, as described in the following section.
Ubuntu is one of the most widely-used flavors of Linux so it's very easy to get help online if you run into problems.
The second decision you'll need 

An AMI is a bootable disk image, including an operating system, software and various files.
When Amazon allocates an instance, this is just a bare machine with


Creating a Amazon Machine Image (AMI)
--------------------------------------
Here I'm assuming that you'll create an EBS-backed image, i.e. that you'll use an EBS-backed instance.
All of the compute-optimized instances are EBS-backed as are the smaller general purpose instance and these are what make the most sense for our purposes.

1. Launch a t2.micro using a public AMI. I'll use Ubuntu Server 14.04 LTS.
2. Log into the instance and install whatever software you want. I'll install R, Rcpp, RcppArmadillo and git as follows:

        sudo apt-get update
        sudo apt-get install -y git
        sudo apt-get install -y r-base
        sudo apt-get install -y r-cran-rcpp
        sudo apt-get install -y r-cran-rcpparmadillo
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
You'll get an email if you've spent more than a certain amount of money.
I set mine to notify me if I ever spend more than ten dollars.
Second is an alarm that automatically stops idle instances.
Amazon [doesn't charge](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Stop_Start.html) you for stopped instances: they only charge you for storage on any attached EBS volumes (see below).
Instances could easily cost over a dollar per hour, but EBS volumes are around ten cents per GB per month.

Elastic Block Storage
----------------------
If you create an instance and terminate it everything on that machine *will be deleted* **unless** you've set up persistent storage.
Fortunately this is easy and cheap using Elastic Block Storage (EBS).
At the time of this writing, new AWS users are entitled to 30GB of EBS storage per month for free. (For more details click [here](http://aws.amazon.com/free/).)
Even if you're not on the free tier, the prices are still very reasonable: at the moment [ten cents](https://aws.amaxon.com/ebs/pricing) per GB per month.
Like EC2, EBS is billed *hourly* so unless you create very large volumes and keep them around for a very long time, this will cost [next to nothing](http://serverfault.com/questions/197379/amazon-ebs-charges-calculation).

When you create an instance, you'll have an option to add storage in Step 4 of the process.
You'll need to choose how many GB to allocate, what kind of storage you want (general purpose is fine for what we'll be doing) and whether you want the volume to persist after you terminate the instance. 
