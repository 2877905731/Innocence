package com.innocence.server.modules.setting.dto.request;

import jakarta.validation.Validation;
import jakarta.validation.Validator;
import org.junit.jupiter.api.Test;

import java.util.Arrays;

import static org.assertj.core.api.Assertions.assertThat;

class UpdateAppearanceSettingRequestTest {

    private final Validator validator = Validation
            .buildDefaultValidatorFactory()
            .getValidator();

    @Test
    void missingThemeModeIsRejected() {
        var request = new UpdateAppearanceSettingRequest();

        assertThat(validator.validate(request))
                .extracting(violation -> violation.getPropertyPath().toString())
                .contains("themeMode");
    }

    @Test
    void desktopEffectIsNotPartOfTheAppearanceContract() {
        assertThat(Arrays.stream(UpdateAppearanceSettingRequest.class.getDeclaredFields())
                .map(field -> field.getName()))
                .doesNotContain("desktopEffect");
    }
}
