%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

void calcularSubrede(char *ip, char *mascara);
void ipToBinary(char *ip, char *bin);
void mascaraToBinary(char *mascara, char *bin);
void calculaRedeBroadcast(char *ip, char *mascara, char *rede, char *broadcast);
void decimalToBinary(int num, char *bin);
char determinarClasse(int primeiroOcteto);

void yyerror(const char *s);
int yylex(void);

%}

%union {
    char str[20];
}

%token <str> IP

%%

input:
    | input line
    ;

line:
    IP IP {
        printf("IP: %s\n", $1);
        printf("Mascara: %s\n", $2);
        calcularSubrede($1, $2);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}

int main() {
    printf("====================================\n");
    printf("      Calculo de Sub-rede\n");
    printf("====================================\n");
    printf("Exemplo de entrada: (IP e Mascara) \n");
    printf("192.168.1.10 255.255.255.0\n");
    printf("====================================\n\n");
    return yyparse();
}

void calcularSubrede(char *ip, char *mascara) {
    char ipBinario[35], mascaraBinario[35];
    ipToBinary(ip, ipBinario);
    mascaraToBinary(mascara, mascaraBinario);

    printf("\nMascara em Binario: %s\n", mascaraBinario);

    // Determinar classe do IP
    int primeiroOcteto;
    sscanf(ip, "%d", &primeiroOcteto);
    char classe = determinarClasse(primeiroOcteto);
    printf("Classe do IP: %c\n", classe);

    // Calcular bits de rede e hosts
    int bitsRede = 0;
    for (int i = 0; i < strlen(mascaraBinario); i++) {
        if (mascaraBinario[i] == '1') bitsRede++;
    }

    int bitsHost = 32 - bitsRede;
    int numSubredes = pow(2, bitsRede % 8);
    int numHosts = pow(2, bitsHost) - 2;

    printf("Numero de Sub-redes: %d\n", numSubredes);
    printf("Numero de Hosts por Sub-rede: %d\n", numHosts);

    char rede[20], broadcast[20];
    calculaRedeBroadcast(ip, mascara, rede, broadcast);
    printf("Endereco de Rede: %s\n", rede);
    printf("Endereco de Broadcast: %s\n\n", broadcast);
}

void ipToBinary(char *ip, char *bin) {
    int octetos[4];
    sscanf(ip, "%d.%d.%d.%d", &octetos[0], &octetos[1], &octetos[2], &octetos[3]);

    char temp[9];
    sprintf(bin, ""); 
    for (int i = 0; i < 4; i++) {
        decimalToBinary(octetos[i], temp);
        strcat(bin, temp);
        if (i < 3) strcat(bin, ".");
    }
}

void mascaraToBinary(char *mascara, char *bin) {
    int octetos[4];
    sscanf(mascara, "%d.%d.%d.%d", &octetos[0], &octetos[1], &octetos[2], &octetos[3]);

    char temp[9];
    sprintf(bin, "");
    for (int i = 0; i < 4; i++) {
        decimalToBinary(octetos[i], temp);
        strcat(bin, temp);
        if (i < 3) strcat(bin, ".");
    }
}

void calculaRedeBroadcast(char *ip, char *mascara, char *rede, char *broadcast) {
    int ipOct[4], maskOct[4];
    sscanf(ip, "%d.%d.%d.%d", &ipOct[0], &ipOct[1], &ipOct[2], &ipOct[3]);
    sscanf(mascara, "%d.%d.%d.%d", &maskOct[0], &maskOct[1], &maskOct[2], &maskOct[3]);

    int redeOct[4], broadcastOct[4];
    for (int i = 0; i < 4; i++) {
        redeOct[i] = ipOct[i] & maskOct[i];
        broadcastOct[i] = redeOct[i] | (~maskOct[i] & 0xFF);
    }

    sprintf(rede, "%d.%d.%d.%d", redeOct[0], redeOct[1], redeOct[2], redeOct[3]);
    sprintf(broadcast, "%d.%d.%d.%d", broadcastOct[0], broadcastOct[1], broadcastOct[2], broadcastOct[3]);
}

void decimalToBinary(int num, char *bin) {
    for (int i = 7; i >= 0; i--) {
        bin[7 - i] = (num & (1 << i)) ? '1' : '0';
    }
    bin[8] = '\0';
}

char determinarClasse(int primeiroOcteto) {
    if (primeiroOcteto >= 0 && primeiroOcteto <= 127) return 'A';
    if (primeiroOcteto >= 128 && primeiroOcteto <= 191) return 'B';
    if (primeiroOcteto >= 192 && primeiroOcteto <= 223) return 'C';
    if (primeiroOcteto >= 224 && primeiroOcteto <= 239) return 'D';
    return 'E';
}
