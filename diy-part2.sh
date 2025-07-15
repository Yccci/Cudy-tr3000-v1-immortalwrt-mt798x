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

MTK_MK="target/linux/mediatek/image/mt7981.mk"
DTS_FILE="target/linux/mediatek/dts/mt7981b-cudy-tr3000-v1.dts"

if [ -f "$DTS_FILE" ]; then
    echo "🛠 正在修改 $DTS_FILE 中 &ubi 的 reg ..."
    if grep -q '&ubi' "$DTS_FILE"; then
        sed -i -E '/&ubi {/,/};/s/reg = <[^>]+>/reg = <0x5C0000 0x1EA00000>/' "$DTS_FILE"
        if grep -q 'reg = <0x5C0000 0x1EA00000>' "$DTS_FILE"; then
            echo "✅ 修改成功: reg = <0x5C0000 0x1EA00000>"
        else
            echo "⚠️ 修改执行了但未生效，请检查格式"
        fi
    else
        echo "❌ 未找到 &ubi 节点，手动检查文件内容"
    fi
else
    echo "❌ DTS 文件不存在：$DTS_FILE"
fi

# 2️⃣ 修改 IMAGE_SIZE（推荐方式）
if grep -q 'cudy_tr3000-v1' "$MTK_MK"; then
    echo "🛠 设置 IMAGE_SIZE 为 512MB..."
    sed -i '/Device\/cudy_tr3000-v1/,/endef/ s/IMAGE_SIZE := .*/IMAGE_SIZE := 522240k/' "$MTK_MK"
else
    echo "⚠️ 未找到 cudy_tr3000-v1 设备定义，请手动检查 $MTK_MK"
fi

echo "🎉 diy-part2.sh 修改完成！"

