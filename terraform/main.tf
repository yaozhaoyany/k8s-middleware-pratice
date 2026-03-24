# 这是 Terraform 项目代码的主入口(Entrypoint)

# 定义了一个 Dummy (占位) 的通用空资源，不会创建真实的云计算实例
resource "null_resource" "trigger_ansible" {
  
  # provisioner "local-exec" 代表让 Terraform 在当前执行此代码的机器（此处即你的本地开发机终端）上运行一行 shell 脚本。
  provisioner "local-exec" {
    command = "echo Terraform is running and ready to trigger Ansible!"
    
    # 【高阶实战玩法剧透】:
    # 当未来你用 Terraform 在内网实验区或者云端真实拉起了一台虚拟机资源（如 aws_instance）后，我们就会利用这个特性，在这里写下：
    # command = "ansible-playbook -i ${aws_instance.db_server.public_ip}, ../ansible/playbooks/setup_node.yml"
    # 从而实现标准的基础设施自动化流水线："Terraform 负责生机器" -> "生完立刻无缝踢给 Ansible" -> "Ansible 负责养机器(初始化环境配置)"。
  }
}
