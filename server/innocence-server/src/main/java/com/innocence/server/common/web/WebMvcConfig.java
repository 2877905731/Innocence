package com.innocence.server.common.web;

import com.innocence.server.modules.report.config.AdminAccessProperties;
import com.innocence.server.modules.account.config.AvatarStorageProperties;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@EnableConfigurationProperties(AdminAccessProperties.class)
public class WebMvcConfig implements WebMvcConfigurer {

    private final AuthInterceptor authInterceptor;
    private final AvatarStorageProperties avatarStorageProperties;

    public WebMvcConfig(AuthInterceptor authInterceptor, AvatarStorageProperties avatarStorageProperties) {
        this.authInterceptor = authInterceptor;
        this.avatarStorageProperties = avatarStorageProperties;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authInterceptor)
                .addPathPatterns(
                        "/api/app/v1/**",
                        "/api/admin/v1/**"
                )
                .excludePathPatterns("/api/app/v1/system/**", "/api/app/v1/auth/**", "/api/admin/v1/auth/login");
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String publicPath = avatarStorageProperties.getPublicPath();
        if (publicPath == null || publicPath.isBlank()) {
            publicPath = "/uploads/avatars";
        }
        publicPath = publicPath.startsWith("/") ? publicPath : "/" + publicPath;
        publicPath = publicPath.replaceAll("/+$", "");
        String location = avatarStorageProperties.storageLocation().toUri().toString();
        if (!location.endsWith("/")) {
            location += "/";
        }
        registry.addResourceHandler(publicPath + "/**")
                .addResourceLocations(location);
    }
}
