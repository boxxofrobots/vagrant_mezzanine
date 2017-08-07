Vagrant.configure("2") do |config|
  config.vm.box = "dummy"
  
  config.vm.provider :aws do |aws, override|
    aws.access_key_id = "YOUR_KEY_ID"
    aws.secret_access_key = "YOUR_ACCESS_KEY"
    aws.keypair_name = "KEYPAIR_NAME"

	#change below to suit recipe
	
    aws.ami = "ami-af4257d6"
    aws.region = "us-west-2"
    aws.instance_type = "t1.micro"
    aws.security_groups = [ "vagrant" ]
	override.vm.provision :shell, path: "script.sh" # Provisioning with script.sh
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = "/home/brad/.ssh/KEYPAIR_NAME.pem"
  end
end
