#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
sed -i 's/192.168.6.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate


# 功能：修改 Cudy TR3000 的 NAND 分区以支持 512MB，并提升 UBI 镜像最大大小限制
echo "✅ 开始执行 diy-part2.sh：修改 dts 和镜像限制..."

DTS_FILE="target/linux/mediatek/dts/mt7981b-cudy-tr3000-v1.dts"
MTK_MK="target/linux/mediatek/image/mt7981.mk"

# 1️⃣ 修改 DTS 分区大小为适配 512MB NAND（起始 0x5C0000，长度 0x1EA00000 ≈ 506MB）
if grep -q 'partition@5c0000' "$DTS_FILE"; then
    echo "🛠 修改设备树中的 ubi 分区 reg 大小..."
    sed -i 's/partition@5c0000.*/partition@5c0000 {\n\t\t\tlabel = "ubi";\n\t\t\treg = <0x5C0000 0x1EA00000>;\n\t\t};/' "$DTS_FILE"
else
    echo "⚠️ 未找到 partition@5c0000，请手动检查 $DTS_FILE"
fi

# 2️⃣ 修改 IMAGE_SIZE（推荐方式）
if grep -q 'cudy_tr3000-v1' "$MTK_MK"; then
    echo "🛠 设置 IMAGE_SIZE 为 512MB..."
    sed -i '/Device\/cudy_tr3000-v1/,/endef/ s/IMAGE_SIZE := .*/IMAGE_SIZE := 522240k/' "$MTK_MK"
else
    echo "⚠️ 未找到 cudy_tr3000-v1 设备定义，请手动检查 $MTK_MK"
fi

echo "🎉 diy-part2.sh 修改完成！"

