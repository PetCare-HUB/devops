package fiap.com.br.petcarehub.validation;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * Testes da regra de idade máxima do pet (@MaxAge).
 * Regra usada no cadastro de pets: a data de nascimento não pode
 * estar no futuro e o pet não pode ter mais de 25 anos.
 *
 * Padrão AAA: Arrange (preparar), Act (executar), Assert (verificar).
 * Não dependem do banco de dados.
 */
class MaxAgeValidatorTest {

    private MaxAgeValidator validator;

    @BeforeEach
    void setUp() {
        // Simula a anotação @MaxAge(25), a mesma usada no PetRequest
        MaxAge anotacao = mock(MaxAge.class);
        when(anotacao.value()).thenReturn(25);

        validator = new MaxAgeValidator();
        validator.initialize(anotacao);
    }

    @Test
    void isValid_petCom4Anos_retornaTrue() {
        // Arrange: pet nascido há 4 anos
        LocalDate nascimento = LocalDate.now().minusYears(4);

        // Act
        boolean resultado = validator.isValid(nascimento, null);

        // Assert: idade dentro do limite, cadastro aceito
        assertTrue(resultado);
    }

    @Test
    void isValid_petCom30Anos_retornaFalse() {
        // Arrange: pet nascido há 30 anos (acima do limite de 25)
        LocalDate nascimento = LocalDate.now().minusYears(30);

        // Act
        boolean resultado = validator.isValid(nascimento, null);

        // Assert: idade acima do limite, cadastro recusado
        assertFalse(resultado);
    }

    @Test
    void isValid_dataNascimentoNoFuturo_retornaFalse() {
        // Arrange: data de nascimento amanhã (impossível)
        LocalDate nascimento = LocalDate.now().plusDays(1);

        // Act
        boolean resultado = validator.isValid(nascimento, null);

        // Assert: data futura, cadastro recusado
        assertFalse(resultado);
    }
}
