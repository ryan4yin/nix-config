# convert all images to png

def to_png [old_path: string, old_format: string] {
  # 将后缀改为 .png 得到新图片的 path
  let webp_path = ($old_path | split row $old_format | append ".png" | str join)
  # 使用 ffmpeg 进行格式转换
  ffmpeg -y -i $old_path $webp_path
  # 删除旧图片
  rm $old_path
}

def convert_format [old_format: string] {
    # 递归找出所有大于 10kib 的图片
    let old_paths = (ls $"**/*($old_format)" | where size > 10kb | each {|it| $it.name})
    $old_paths | to md

    # 1. 执行图片格式转换与压缩，同时删除原图片
    $old_paths | each { |it| to_png $it $old_format }
}

convert_format ".webp"
# convert_format ".jpg"
