# run incrementail scrapes
# usage: 0 */6 * * * (cd FedWiki/search; LANG="en_US.UTF-8" sh cron.sh)

mkdir -p activity logs sites
NOW=`date -u +%a-%H00`

find logs -mtime +7 -exec rm {} \;
ruby scrape.rb > logs/$NOW


find sites -name words.txt -newer words.txt | \
	cut -d / -f 2 | \
	perl -pe 's/^www\.//' | \
	sort | uniq > activity/$NOW

ruby rollup.rb
ls sites | while read site; do ls sites/$site/pages; done | sort | uniq > slugs.txt
ls sites | \
  while read site; do
    if [ `ls sites/$site/pages | wc -l` != "0" ] ; then
       ls sites/$site/pages > sites/$site/slugs.txt
       ls sites/$site/pages | \
         while read slug; do
           printf "%s\n" "$slug" > sites/$site/pages/$slug/slugs.txt
         done
    fi
  done
tar czf public/sites.tgz sites *.txt retired

find activity -mtime +7 -exec rm {} \;
ruby found.rb $NOW
ruby activity.rb

ruby site-web.rb > public/site-web.json
(perl -e 'print "window.sites="'; cat public/site-web.json) > public/site-web.js
ruby slug-web.rb > public/slug-web.json
(perl -e 'print "window.slugs="'; cat public/slug-web.json) > public/slug-web.js

ruby neo-batch.rb
sh neo-build.sh
