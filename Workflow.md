# Workflow de commit

## Puxando a branch principal

```sh
git pull origin develop
```

## Criando uma branch

```sh
git checkout -b nome-da-branch
```
> Prefixos 
- feat/ - nova funcionalidade
- fix/ - correção de bug
- docs/ - documentação
- style/ - formatação, ponto e vírgula, etc; sem mudanças de código
- refactor/ - refatoração de código

## Commitando as mudancas

```sh
git add .
git commit -m "feat: descrição da mudança"
git push origin nome-da-branch
```

## Fazendo o merge request

```sh
git checkout develop
git pull origin develop
git merge nome-da-branch
git push origin develop
```

## Deletando a branch antiga

```sh
git branch -d nome-da-branch
```