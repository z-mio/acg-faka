FROM php:8.1-apache

# 安装系统依赖与 PHP 扩展
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libfreetype-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        libssl-dev \
        openssl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql zip sockets \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录（Apache 默认站点目录）
WORKDIR /var/www/html

# 复制项目到容器
COPY . /var/www/html

# 启用 Apache 重写模块（.htaccess 已在项目根目录）
RUN a2enmod rewrite

# 可选：设置部分 PHP 运行参数（根据需要调整）
RUN { \
      echo "date.timezone=Asia/Shanghai"; \
      echo "memory_limit=256M"; \
      echo "upload_max_filesize=50M"; \
      echo "post_max_size=50M"; \
   } > /usr/local/etc/php/conf.d/project.ini

# 设置权限（确保 Apache 可写入必要目录）
RUN chown -R www-data:www-data /var/www/html

# 暴露端口
EXPOSE 80