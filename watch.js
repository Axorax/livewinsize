import { readdir, stat, readFile, mkdir, copyFile, existsSync } from 'fs';
import { join, extname } from 'path';
import { exec } from 'child_process';

const watchDirectories = ['./compiled', './src-tauri'];
const command = 'npm run tauri';
const fileStates = {};

function runCommand(cmd) {
	exec(cmd, (error, stdout, stderr) => {
		if (error) console.error(`[watcher] Error: ${error}`);
		console.log(stdout);
		console.log(stderr);
	});
}

function addCheck(directory, file) {
	const filePath = join(directory, file);
	stat(filePath, (err, stats) => {
		if (err) {
			console.error(`[watcher] Error getting file stats for ${filePath}: ${err}`);
			return;
		}

		if (stats.isFile()) {
			readFile(filePath, 'utf8', (err, data) => {
				if (err) {
					console.error(`[watcher] Error reading file ${filePath}: ${err}`);
					return;
				}

				const prevState = fileStates[filePath] || {};
				if (prevState.content !== data) {
					const ext = extname(filePath);
					if (ext === '.less') {
						runCommand("npm run less");
					}
					runCommand(command);
					fileStates[filePath] = { content: data, mtime: stats.mtime };
				}
			});
		}
	});
}

function checkFileChanges() {
	addCheck('./src', 'style.less');
	for (const directory of watchDirectories) {
		readdir(directory, (err, files) => {
			if (err) {
				console.error(`[watcher] Error reading directory: ${directory}: ${err}`);
				return;
			}

			files.forEach((file) => {
				addCheck(directory, file)
			});
		});
	}
}

function compiledDirAndFont() {
	const directory = './compiled';
	const srcFile = './src/manrope.woff2';
	const destFile = join(directory, 'manrope.woff2');

	if (!existsSync(directory)) {
		mkdir(directory, (err) => {
			if (err) console.error(`[watcher] Error creating directory: ${directory}: ${err}`);
			else copyFontFile(srcFile, destFile);
		});
	} else {
		copyFontFile(srcFile, destFile);
	}
}

function copyFontFile(src, dest) {
	copyFile(src, dest, (err) => {
		if (err) console.error(`[watcher] Error copying file: ${err}`);
		else console.log(`[watcher] Copied ${src} to ${dest}`);
	});
}

const args = process.argv.slice(2);

if (args.includes('-once')) {
	runCommand('npm run pug');
	runCommand('npm run cs');
	runCommand('npm run less');
	runCommand('npm run tauri');
	compiledDirAndFont();
} else {
	runCommand('npm run pug');
	runCommand('npm run cs');
	runCommand('npm run less');
	runCommand('npm run tauri');
	compiledDirAndFont();
	setInterval(checkFileChanges, 1000);
}
