# convert all png/jpeg images to webp

def to_webp [old_path: string, old_format: string] {
  # 将后缀改为 .webp 得到新图片的 path
  let webp_path = ($old_path | split row $old_format | append ".webp" | str collect)
  # 使用 ffmpeg 进行格式转换
  ffmpeg -y -i $old_path -c:v libwebp $webp_path
  # 删除旧图片
  rm $old_path
}

def replace_with_webp [old_path: string, old_format: string] {
  # 将后缀改为 .webp 得到新图片的 path
  let webp_path = ($old_path | split row $old_format | append ".webp" | str collect)
  # 图片的旧名称与新名称
  let old_name = ($old_path | path basename)
  let webp_name = ($webp_path | path basename)
  # 批量将 .md 文件中的所有图片名称，改为对应的 webp 图片名称
  # 注：MacOS 需要首先安装好 gsed，Linux 请将下面的 gsed 替换为 sed
  let cmd = $"gsed -ri 's/($old_name)/($webp_name)/g' `find . -name "*.md"`"
  echo $cmd
  bash -c $cmd
}

def convert_format(old_format: string) {
    # 递归找出所有大于 10kib 的图片
    let old_paths = (ls $"**/*($old_format)" | where size > 10kb | each {|it| $it.name})
    $old_paths | to md | save --raw ./old_paths.txt

    # 1. 执行图片格式转换与压缩，同时删除原图片
    $old_paths | each { |it| to_webp $it $old_format }
    # 2. 执行 .md 文档中的图片名称替换
    $old_paths | each { |it| replace_with_webp $it $old_format }
}

convert_format ".png"
convert_format ".jpg"