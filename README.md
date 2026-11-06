# Заявки на автоматизацию

https://zed1kgit.github.io/automation-requests/

Веб-сервис: регистрация и вход по почте и паролю, создание и редактирование заявок, смена статуса, поиск и фильтр. Данные и авторизация — Supabase. Фронтенд — один файл `index.html` (HTML/CSS/JS без сборки, `supabase-js` с CDN).

## Настройка Supabase

1. Создайте проект на supabase.com.
2. SQL Editor → вставьте и выполните `supabase/schema.sql`. Он создаёт таблицу `requests`, ограничения, триггер и политики RLS.
3. Project Settings → API: скопируйте **Project URL** и **anon public key**.
4. В `index.html` в блоке «Настройки Supabase» подставьте их в `SUPABASE_URL` и `SUPABASE_ANON_KEY`. Anon-ключ публичный по дизайну; `service_role` ключ в проект не добавлять.
5. Authentication → Sign In / Providers → Confirm email включён. Для быстрой проверки можно отключить (иначе после регистрации нужно подтвердить почту).
6. Authentication → URL Configuration: добавьте адрес развёрнутого приложения в Site URL.

## Запуск

Локально: `npx serve .` или `python3 -m http.server`, затем откройте http://localhost:3000 (или :8000).
Публикация: загрузите папку на Vercel, Netlify или GitHub Pages (сборка не нужна).

## Как устроен доступ

RLS включён, политики `select/insert/update/delete` проверяют `auth.uid() = user_id`. `user_id` ставится по умолчанию из `auth.uid()`, а триггер запрещает менять владельца при update. Роль `anon` не имеет прав на таблицу. Ограничение действует на уровне БД, поэтому прямой запрос к REST API с токеном другого пользователя вернёт пустой результат.

Проверка прямым запросом (токен пользователя B, id заявки пользователя A):

```
curl "$SUPABASE_URL/rest/v1/requests?id=eq.<ID_заявки_A>" \
  -H "apikey: $ANON_KEY" -H "Authorization: Bearer <JWT_пользователя_B>"
```
