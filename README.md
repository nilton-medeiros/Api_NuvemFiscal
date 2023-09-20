# API de integração com a Nuvem Fiscal
A API NuvemFiscal é uma solução avançada de integração que se destina a facilitar a comunicação entre o seu sistema, Sefaz (Secretaria da Fazenda) e prefeituras para a autorização de documentos fiscais. Sua principal funcionalidade é a sua capacidade de integração com o provedor "Nuvem Fiscal" Rest API de uma forma simples e rápida.

Aqui estão alguns dos principais recursos e funcionalidades da API NuvemFiscal:

1. **Integração com Nuvem Fiscal Rest API**: As classes são capaz de se conectar de forma eficiente ao provedor "Nuvem Fiscal" através da sua API Rest. Isso permite uma comunicação ágil e segura com a Sefaz, Prefeituras e NFSe-NAC para a autorização de documentos fiscais.

2. **Geração de XML**: A classe é capaz obter arquivos XML de forma automática, o que é essencial para a emissão de documentos fiscais eletrônicos.

3. **DACTE/DAMFE em PDF**: Além de obter o XML, o sistema também é capaz de obter o Documento Auxiliar do Conhecimento de Transporte Eletrônico (DACTE) em formato PDF. Isso torna mais fácil para a sua empresa compartilhar e armazenar esses documentos de maneira digital.

4. **Armazenamento na Nuvem**: Uma característica importante é a capacidade de armazenar os arquivos gerados na nuvem. Isso não só ajuda na organização dos documentos, mas também garante a sua segurança e disponibilidade a qualquer momento.

5. **Processamento no Servidor da Empresa Emitente**: Sua aplicação utilizado a classe API NuvemFiscal pode operar no servidor da empresa emitente, garantindo assim maior controle e flexibilidade sobre o processo de emissão de documentos fiscais.

Essas são algumas das características essenciais da API Nuvem Fiscal, que tem como objetivo facilitar e otimizar o processo de autorização de documentos fiscais, tornando-o mais eficiente e confiável para a sua pequena empresa de sistemas.

### Dependências
    Compilado com Harbour 3.2.0dev (r1703241902)
    HMG 3.4.4 Stable (32 bit) HMG-IDE UNICODE ver 1.2a
    saveLog(): função que gera um arquivo de log
    consoleLog(): função para debug, gera um log das ocorrências

#
Nota: Para saber como usa-las veja os exemplos:
* example_empresas.prg
* example_certificado.prg

As classes ApiCTe.prg e ApiMDFe.prg estão em desenvolvimento, assim que terminar e testar disponibilizo aqui.
#### Você pode ajudar colaborando com um código mais limpo, dar sugestões ou comentar os defeitos, mas já comenta com a solução!

## TMS.Cloud
* Sistema de Gerenciamento de Transporte
* Faturamento sobre CTEs emitidos
* Emissão da MDFe
#
https://sistrom.com.br/